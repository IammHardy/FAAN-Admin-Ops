class DispatchesController < ApplicationController
 before_action :require_dispatch_access!, only: [:index, :new, :create, :edit, :update, :destroy, :pending, :search, :mark_dispatched, :mark_filed, :print, :pending_acknowledgement, :ready_to_file, :filed]
before_action :require_dispatch_receiver_access!, only: [:show, :mark_received, :mark_acknowledged, :incoming]
before_action :require_admin_access!, only: [:destroy]

before_action :set_dispatch, only: [
  :show, :edit, :update, :destroy,
  :mark_dispatched, :mark_received, :mark_acknowledged, :mark_filed, :print
]

before_action :authorize_receiving_unit!, only: [:show, :mark_received, :mark_acknowledged]
before_action :load_dispatch_form_collections, only: [:new, :create, :edit, :update]
  def index
    @dispatches = Dispatch.includes(:sender_department, :receiving_department, :created_by).recent_first
  end

def show
  @audit_logs = AuditLog.includes(:user).where(auditable: @dispatch).recent_first
end

  def new
    @dispatch = Dispatch.new(memo_date: Date.current)
  end

  def create
    @dispatch = Dispatch.new(dispatch_params)
    @dispatch.created_by = current_user

    if @dispatch.save
  sync_dispatch_recipients

      AuditLogger.call(
        user: current_user,
        action: "create",
        auditable: @dispatch,
        description: "Created dispatch #{@dispatch.reference_number}"
      )

      redirect_to @dispatch, success: "Dispatch record created successfully."
    else
      flash.now[:error] = "Unable to create dispatch record."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @dispatch.update(dispatch_params)
  sync_dispatch_recipients
      AuditLogger.call(
        user: current_user,
        action: "update",
        auditable: @dispatch,
        description: "Updated dispatch #{@dispatch.reference_number}"
      )

      redirect_to @dispatch, success: "Dispatch record updated successfully."
    else
      flash.now[:error] = "Unable to update dispatch record."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    reference_number = @dispatch.reference_number
    @dispatch.destroy

    AuditLogger.call(
      user: current_user,
      action: "delete",
      auditable: @dispatch,
      description: "Deleted dispatch #{reference_number}"
    )

    redirect_to dispatches_path, success: "Dispatch record deleted successfully."
  rescue ActiveRecord::InvalidForeignKey
    redirect_to dispatches_path, error: "Dispatch record cannot be deleted."
  end

  def pending
    @dispatches = Dispatch.pending.recent_first
    render :index
  end

  def search
    @dispatches = Dispatch.includes(:sender_department, :receiving_department, :created_by).recent_first

    if params[:reference_number].present?
      @dispatches = @dispatches.where("reference_number ILIKE ?", "%#{params[:reference_number]}%")
    end

    if params[:subject].present?
      @dispatches = @dispatches.where("subject ILIKE ?", "%#{params[:subject]}%")
    end

    if params[:status].present?
      @dispatches = @dispatches.where(status: params[:status])
    end

    if params[:memo_date].present?
      @dispatches = @dispatches.where(memo_date: params[:memo_date])
    end

    render :index
  end

  def pending_acknowledgement
  @dispatches = Dispatch
    .joins(:dispatch_recipients)
    .where(dispatch_recipients: { status: [:dispatched, :received] })
    .distinct
    .recent_first

  render :index
end

def ready_to_file
  @dispatches = Dispatch
    .includes(:dispatch_recipients)
    .select(&:all_recipients_acknowledged?)

  render :index
end

def filed
  @dispatches = Dispatch.filed.recent_first
  render :index
end

  def mark_dispatched
    @dispatch.mark_as_dispatched!(current_user)

    AuditLogger.call(
      user: current_user,
      action: "mark_dispatched",
      auditable: @dispatch,
      description: "Marked dispatch #{@dispatch.reference_number} as dispatched"
    )

    redirect_to @dispatch, success: "Dispatch marked as dispatched."
  rescue StandardError => e
    redirect_to @dispatch, error: e.message
  end

 def mark_received
  recipient = @dispatch.dispatch_recipients.find_by!(
    receiving_unit_id: current_user.unit_id
  )

  recipient.mark_as_received!(
    receiver_name: params[:receiver_name],
    receiver_designation: params[:receiver_designation],
    user: current_user
  )

  AuditLogger.call(
    user: current_user,
    action: "mark_received",
    auditable: @dispatch,
    description: "Received dispatch #{@dispatch.reference_number} for #{recipient.receiving_unit.name}"
  )

  redirect_to @dispatch, success: "Dispatch received successfully."
rescue StandardError => e
  redirect_to @dispatch, error: e.message
end

 def mark_acknowledged
  recipient = @dispatch.dispatch_recipients.find_by!(
    receiving_unit_id: current_user.unit_id
  )

  recipient.mark_as_acknowledged!(
    user: current_user,
    note: params[:acknowledgement_note]
  )

  AuditLogger.call(
    user: current_user,
    action: "mark_acknowledged",
    auditable: @dispatch,
    description: "Acknowledged dispatch #{@dispatch.reference_number} for #{recipient.receiving_unit.name}"
  )

  redirect_to @dispatch, success: "Dispatch acknowledged successfully."
rescue StandardError => e
  redirect_to @dispatch, error: e.message
end

  def mark_filed
    @dispatch.mark_as_filed!

    AuditLogger.call(
      user: current_user,
      action: "mark_filed",
      auditable: @dispatch,
      description: "Marked dispatch #{@dispatch.reference_number} as filed"
    )

    redirect_to @dispatch, success: "Dispatch marked as filed."
  rescue StandardError => e
    redirect_to @dispatch, error: e.message
  end

  def print
    render layout: "print"
  end

  def incoming
  @dispatch_recipients = DispatchRecipient
    .includes(:dispatch, :receiving_unit)
    .where(receiving_unit_id: current_user.unit_id)
    .recent_first
end

  private

  def set_dispatch
    @dispatch = Dispatch.find(params[:id])
  end

  def load_dispatch_form_collections
    @departments = Department.active.order(:name)
    @units = Unit.active.includes(:department).order(:name)
    @users = User.active.order(:full_name)
  end

  
  def sync_dispatch_recipients
  unit_ids = params.dig(:dispatch, :receiving_unit_ids)&.reject(&:blank?) || []

  @dispatch.dispatch_recipients.where.not(receiving_unit_id: unit_ids).destroy_all

  unit_ids.each do |unit_id|
    @dispatch.dispatch_recipients.find_or_create_by!(receiving_unit_id: unit_id) do |recipient|
      recipient.status = @dispatch.dispatched? ? :dispatched : :dispatched
    end
  end
end

  def dispatch_params
  params.require(:dispatch).permit(
    :reference_number,
    :subject,
    :memo_date,
    :sender_department_id,
    :sender_unit_id,
    :receiving_department_id,
    :delivery_note,
    :remarks,
    :memo_file,
    receiving_unit_ids: []
  )
end

  def authorize_receiving_unit!
  return if current_user.super_admin? || current_user.admin_officer? || current_user.dispatch_officer?

  if current_user.unit_officer?
    return if @dispatch.dispatch_recipients.exists?(receiving_unit_id: current_user.unit_id)
  end

  redirect_to dashboard_path, error: "You are not authorized to access this dispatch."
end
end