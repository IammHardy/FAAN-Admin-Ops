module Reports
  class SummariesController < ApplicationController
    def daily
      @date = params[:date].present? ? Date.parse(params[:date]) : Date.current

      @dispatches = Dispatch.where(memo_date: @date)
      @log_reports = LogReport.where(report_date: @date)
      @incidents = Incident.where(created_at: @date.all_day)
    end

    def monthly
      selected_date = params[:month].present? ? Date.parse("#{params[:month]}-01") : Date.current.beginning_of_month

      @month_start = selected_date.beginning_of_month
      @month_end = selected_date.end_of_month

      @dispatches = Dispatch.where(memo_date: @month_start..@month_end)
      @log_reports = LogReport.where(report_date: @month_start..@month_end)
      @incidents = Incident.where(created_at: @month_start.beginning_of_day..@month_end.end_of_day)
    end
  end
end