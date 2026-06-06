class RecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_super_admin!, only: [:deleted, :restore]
  before_action :require_active_duty_session!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_record, only: [:show, :edit, :update, :destroy, :download_attachment, :restore]
  def index
    @records = Record.active.search(params)
                     .includes(:filed_by, :operation_staff, duty_session: :operation_staff)
                     .recent
                     .page(params[:page])
                     .per(15)
                     
  end

  def show
  end

  def new
    @record = Record.new(filed_date: Date.current)
  end

  def create
    @record = Record.new(record_params)
    @record.filed_by = current_user
    @record.duty_session = current_duty_session

    if @record.save
      AuditLogger.call(
        user: current_user,
        action: "create",
        auditable: @record,
        description: "Created record #{@record.title}"
      )

      redirect_to @record, notice: "Record was successfully added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @record.update(record_params)
      AuditLogger.call(
        user: current_user,
        action: "update",
        auditable: @record,
        description: "Updated record #{@record.title}"
      )

      redirect_to @record, notice: "Record was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

 def destroy
  record_title = @record.title

  if @record.soft_delete!(current_user)
    AuditLogger.call(
      user: current_user,
      action: "delete",
      auditable: @record,
      description: "Soft deleted record #{record_title}"
    )

    redirect_to records_path, notice: "Record was moved to deleted records."
  else
    redirect_to @record, alert: "Record could not be deleted."
  end
end

  def daily_log
    @selected_date = params[:filed_date].presence || Date.current.to_s

    @records = Record.active
  .where(filed_date: @selected_date)
  .includes(:filed_by, :operation_staff, duty_session: :operation_staff)
  .order(:category, :title)
  end
  def download_attachment
  unless @record.attachment.attached?
    redirect_to @record, alert: "No attachment found."
    return
  end

  redirect_to rails_blob_path(@record.attachment, disposition: "attachment")
end

def deleted
  @records = Record.deleted
                   .includes(:filed_by, :operation_staff, :deleted_by)
                   .order(deleted_at: :desc)
                   .page(params[:page])
                   .per(15)
end

def restore
  if @record.restore!
    AuditLogger.call(
      user: current_user,
      action: "restore",
      auditable: @record,
      description: "Restored record #{@record.title}"
    )

    redirect_to @record, notice: "Record restored successfully."
  else
    redirect_to deleted_records_path, alert: "Record could not be restored."
  end
end

  private

  def set_record
    @record = Record.find(params[:id])
  end

  def record_params
    params.require(:record).permit(
      :title,
      :category,
      :document_date,
      :filed_date,
      :signed_by,
      :recipient_or_source,
      :reference_number,
      :physical_location,
      :notes,
      :attachment,
      :operation_staff_id
    )
  end
end