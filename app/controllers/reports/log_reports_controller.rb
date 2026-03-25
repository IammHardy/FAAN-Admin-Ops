module Reports
  class LogReportsController < ApplicationController
    def index
      @log_reports = LogReport.includes(:department, :unit, :entered_by).recent_first

      if params[:from].present?
        @log_reports = @log_reports.where("report_date >= ?", params[:from])
      end

      if params[:to].present?
        @log_reports = @log_reports.where("report_date <= ?", params[:to])
      end

      if params[:department_id].present?
        @log_reports = @log_reports.where(department_id: params[:department_id])
      end

      if params[:unit_id].present?
        @log_reports = @log_reports.where(unit_id: params[:unit_id])
      end
    end
  end
end