class LogEntriesController < ApplicationController
  before_action :set_log_report
  before_action :set_log_entry, only: [:edit, :update, :destroy, :create_incident]
  before_action :require_log_access!
before_action :authorize_log_entry_access!
before_action :ensure_log_report_is_editable!, only: [:new, :create, :edit, :update, :destroy]
before_action :require_reviewer_or_admin!, only: [:create_incident]
  

  def new
    @log_entry = @log_report.log_entries.new
  end

  def create
  @log_entry = @log_report.log_entries.new(log_entry_params)

  if @log_entry.save
    @log_entries = @log_report.log_entries.order(entry_time: :asc, created_at: :asc)

    respond_to do |format|
      format.html { redirect_to @log_report, notice: "Log entry added successfully." }
      format.turbo_stream
    end
  else
    redirect_to @log_report, alert: @log_entry.errors.full_messages.to_sentence
  end
end

  def edit
  end

  def update
    if @log_entry.update(log_entry_params)
      redirect_to @log_report, notice: "Log entry updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @log_entry.destroy
    redirect_to @log_report, notice: "Log entry deleted successfully."
  end

  def create_incident
    unless @log_entry.incident_flag?
      redirect_to @log_report, alert: "Only flagged log entries can become incidents."
      return
    end

    if @log_entry.incident.present?
      redirect_to @log_report, alert: "Incident already exists for this log entry."
      return
    end

    incident = Incident.create!(
      log_report: @log_report,
      log_entry: @log_entry,
      title: @log_entry.short_description,
      description: @log_entry.description,
      action_taken: @log_entry.action_taken,
      incident_type: :operational,
      severity: :medium,
      status: :open,
      created_by: current_user
    )

    redirect_to incident_path(incident), notice: "Incident created from log entry."
  end

  private

  def set_log_report
    @log_report = LogReport.find(params[:log_report_id])
  end

  

  def set_log_entry
    @log_entry = @log_report.log_entries.find(params[:id])
  end

  def authorize_log_entry_access!
  return if current_user.super_admin? || current_user.admin_officer?

  if current_user.unit_officer?
    return if current_user.unit_id == @log_report.unit_id
  end

  if current_user.reviewer?
    return if action_name.in?(%w[create_incident])
  end

  redirect_to log_reports_path, error: "You are not authorized to manage this log entry."
end

def ensure_log_report_is_editable!
  return if @log_report.draft?

  redirect_to @log_report, error: "Submitted or reviewed log reports cannot be edited."
end

  def log_entry_params
    params.require(:log_entry).permit(
      :entry_time,
      :description,
      :action_taken,
      :incident_flag,
      :follow_up_needed
    )
  end
end