class IncidentsController < ApplicationController
  before_action :require_incident_access!
  before_action :set_incident, only: [:show, :edit, :update, :destroy, :review, :escalate, :resolve, :close, :print]
  before_action :load_incident_form_collections, only: [:new, :create, :edit, :update]
  before_action :require_reviewer_or_admin!, only: [:review, :escalate, :resolve, :close]
  before_action :require_admin_access!, only: [:destroy]

  def index
    @incidents = Incident.includes(:log_report, :log_entry, :created_by, :reviewed_by).recent_first
  end

  def show
  end

  def new
    @incident = Incident.new
    @incident.log_report_id = params[:log_report_id]
    @incident.log_entry_id = params[:log_entry_id]
  end

  def create
    @incident = Incident.new(incident_params)
    @incident.created_by = current_user

    if @incident.save
      AuditLogger.call(
        user: current_user,
        action: "create",
        auditable: @incident,
        description: "Created incident #{@incident.incident_number}"
      )

      redirect_to @incident, success: "Incident created successfully."
    else
      flash.now[:error] = "Unable to create incident."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @incident.update(incident_params)
      AuditLogger.call(
        user: current_user,
        action: "update",
        auditable: @incident,
        description: "Updated incident #{@incident.incident_number}"
      )

      redirect_to @incident, success: "Incident updated successfully."
    else
      flash.now[:error] = "Unable to update incident."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    incident_number = @incident.incident_number
    @incident.destroy

    AuditLogger.call(
      user: current_user,
      action: "delete",
      auditable: @incident,
      description: "Deleted incident #{incident_number}"
    )

    redirect_to incidents_path, success: "Incident deleted successfully."
  end

  def review
    @incident.review!(
      reviewer: current_user,
      remark: params[:reviewer_remark]
    )

    AuditLogger.call(
      user: current_user,
      action: "review",
      auditable: @incident,
      description: "Marked incident #{@incident.incident_number} under review"
    )

    redirect_to @incident, success: "Incident marked under review."
  rescue StandardError => e
    redirect_to @incident, error: e.message
  end

  def escalate
    @incident.escalate!(
      reviewer: current_user,
      escalated_to: params[:escalated_to],
      remark: params[:reviewer_remark]
    )

    AuditLogger.call(
      user: current_user,
      action: "escalate",
      auditable: @incident,
      description: "Escalated incident #{@incident.incident_number} to #{params[:escalated_to]}"
    )

    redirect_to @incident, success: "Incident escalated successfully."
  rescue StandardError => e
    redirect_to @incident, error: e.message
  end

  def resolve
    @incident.resolve!(
      reviewer: current_user,
      remark: params[:reviewer_remark]
    )

    AuditLogger.call(
      user: current_user,
      action: "resolve",
      auditable: @incident,
      description: "Resolved incident #{@incident.incident_number}"
    )

    redirect_to @incident, success: "Incident resolved successfully."
  rescue StandardError => e
    redirect_to @incident, error: e.message
  end

  def close
    @incident.close!(
      reviewer: current_user,
      remark: params[:reviewer_remark]
    )

    AuditLogger.call(
      user: current_user,
      action: "close",
      auditable: @incident,
      description: "Closed incident #{@incident.incident_number}"
    )

    redirect_to @incident, success: "Incident closed successfully."
  rescue StandardError => e
    redirect_to @incident, error: e.message
  end

  def open_items
    @incidents = Incident.open_items.recent_first
    render :index
  end

  def escalated
    @incidents = Incident.where(status: :escalated).recent_first
    render :index
  end

  def print
    render layout: "print"
  end

  private

  def set_incident
    @incident = Incident.find(params[:id])
  end

  def load_incident_form_collections
    @log_reports = LogReport.recent_first
    @log_entries = LogEntry.flagged_as_incident.includes(:log_report).order(created_at: :desc)
  end

  def incident_params
    params.require(:incident).permit(
      :log_report_id,
      :log_entry_id,
      :title,
      :description,
      :incident_type,
      :severity,
      :action_taken,
      :escalation_required,
      :escalated_to,
      :status,
      :reviewer_remark
    )
  end
end