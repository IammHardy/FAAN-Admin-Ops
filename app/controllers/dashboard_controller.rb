class DashboardController < ApplicationController
  def index
    @dispatches_today = Dispatch.where(created_at: Time.zone.today.all_day).count
    @pending_dispatches = Dispatch.pending.count

    @log_reports_today = LogReport.where(report_date: Date.current).count

    @incidents_today = Incident.where(created_at: Time.zone.today.all_day).count
    @open_incidents = Incident.open_items.count
    @escalated_incidents = Incident.where(status: :escalated).count

    @recent_dispatches = Dispatch.recent_first.limit(5)
    @recent_log_reports = LogReport.recent_first.limit(5)
    @recent_incidents = Incident.recent_first.limit(5)
  end
end