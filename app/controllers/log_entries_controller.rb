class LogEntriesController < ApplicationController
  before_action :require_log_access!
  before_action :set_log_report
  before_action :set_log_entry, only: [:edit, :update, :destroy]
  before_action :authorize_log_entry_access!

  def create
    @log_entry = @log_report.log_entries.build(log_entry_params)

    if @log_entry.save
      AuditLogger.call(
        user: current_user,
        action: "create",
        auditable: @log_entry,
        description: "Added log entry to report dated #{@log_report.report_date}"
      )

      redirect_to @log_report, success: "Log entry added successfully."
    else
      redirect_to @log_report, error: @log_entry.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @log_entry.update(log_entry_params)
      AuditLogger.call(
        user: current_user,
        action: "update",
        auditable: @log_entry,
        description: "Updated log entry in report dated #{@log_report.report_date}"
      )

      redirect_to @log_report, success: "Log entry updated successfully."
    else
      flash.now[:error] = "Unable to update log entry."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @log_entry.destroy

    AuditLogger.call(
      user: current_user,
      action: "delete",
      auditable: @log_report,
      description: "Deleted a log entry from report dated #{@log_report.report_date}"
    )

    redirect_to @log_report, success: "Log entry deleted successfully."
  end

  private

  def set_log_report
    @log_report = LogReport.find(params[:log_report_id])
  end

  def set_log_entry
    @log_entry = @log_report.log_entries.find(params[:id])
  end

  def authorize_log_entry_access!
    return if current_user.super_admin? || current_user.admin_officer? || current_user.reviewer?
    return if current_user.unit_officer? && current_user.unit_id == @log_report.unit_id

    redirect_to log_reports_path, error: "You are not authorized to access this log entry."
  end

  def log_entry_params
    params.require(:log_entry).permit(
      :entry_time,
      :description,
      :incident_flag,
      :action_taken,
      :follow_up_needed
    )
  end
end