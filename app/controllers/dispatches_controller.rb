class DispatchesController < ApplicationController
  before_action :require_dispatch_access!
  before_action :require_admin_access!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_dispatch, only: [
    :show, :edit, :update, :destroy,
    :mark_dispatched, :mark_received, :mark_acknowledged, :mark_filed, :print
  ]
  before_action :load_dispatch_form_collections, only: [:new, :create, :edit, :update]

  def index
    @dispatches = Dispatch.includes(:sender_department, :receiving_department, :created_by).recent_first
  end

  def show
  end

  def new
    @dispatch = Dispatch.new(memo_date: Date.current)
  end

  def create
    @dispatch = Dispatch.new(dispatch_params)
    @dispatch.created_by = current_user

    if @dispatch.save
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
    receiver_name = params[:receiver_name]
    receiver_designation = params[:receiver_designation]

    @dispatch.mark_as_received!(
      receiver_name: receiver_name,
      receiver_designation: receiver_designation
    )

    AuditLogger.call(
      user: current_user,
      action: "mark_received",
      auditable: @dispatch,
      description: "Marked dispatch #{@dispatch.reference_number} as received by #{receiver_name}"
    )

    redirect_to @dispatch, success: "Dispatch marked as received."
  rescue StandardError => e
    redirect_to @dispatch, error: e.message
  end

  def mark_acknowledged
    @dispatch.mark_as_acknowledged!

    AuditLogger.call(
      user: current_user,
      action: "mark_acknowledged",
      auditable: @dispatch,
      description: "Marked dispatch #{@dispatch.reference_number} as acknowledged"
    )

    redirect_to @dispatch, success: "Dispatch marked as acknowledged."
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

  private

  def set_dispatch
    @dispatch = Dispatch.find(params[:id])
  end

  def load_dispatch_form_collections
    @departments = Department.active.order(:name)
    @units = Unit.active.includes(:department).order(:name)
    @users = User.active.order(:full_name)
  end

  def dispatch_params
    params.require(:dispatch).permit(
      :reference_number,
      :subject,
      :memo_date,
      :sender_department_id,
      :sender_unit_id,
      :receiving_department_id,
      :receiving_unit_id,
      :delivery_note,
      :remarks,
      :memo_file
    )
  end
end