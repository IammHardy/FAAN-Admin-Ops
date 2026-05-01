class DashboardController < ApplicationController

  def index
  if current_user.reviewer?
    reviewer_dashboard
  elsif current_user.unit_officer?
    unit_officer_dashboard
  else
    general_dashboard
  end
end

  private

  def reviewer_dashboard
    @pending_review_count = LogReport.submitted.count
    @reviewed_reports_count = LogReport.reviewed.count
    @log_reports_today = LogReport.where(report_date: Date.current).count

    @pending_reviews = LogReport
      .includes(:department, :unit, :entered_by, :submitted_by)
      .where(status: :submitted)
      .recent_first
      .limit(10)

    @recent_reviewed_reports = LogReport
      .includes(:department, :unit, :entered_by, :submitted_by)
      .where(status: :reviewed)
      .recent_first
      .limit(5)
  end

  def unit_officer_dashboard
  @today_log = LogReport.find_by(
    report_date: Date.current,
    unit_id: current_user.unit_id
  )

  @draft_logs = LogReport
    .where(unit_id: current_user.unit_id, status: :draft)
    .recent_first
    .limit(5)

  @submitted_logs = LogReport
    .where(unit_id: current_user.unit_id, status: :submitted)
    .recent_first
    .limit(5)

  @reviewed_logs = LogReport
    .where(unit_id: current_user.unit_id, status: :reviewed)
    .recent_first
    .limit(5)
end

  def general_dashboard
    @dispatches_today = Dispatch.where(created_at: Time.zone.today.all_day).count
    @pending_dispatches = Dispatch.pending.count

    @log_reports_today = LogReport.where(report_date: Date.current).count

    @incidents_today = Incident.where(created_at: Time.zone.today.all_day).count
    @open_incidents = Incident.open_items.count
    @escalated_incidents = Incident.where(status: :escalated).count

    @recent_dispatches = Dispatch.recent_first.limit(5)
    @recent_log_reports = LogReport.recent_first.limit(5)
    @recent_incidents = Incident.recent_first.limit(5)
    @recent_audit_logs = AuditLog.includes(:user).recent_first.limit(8)
  end
end