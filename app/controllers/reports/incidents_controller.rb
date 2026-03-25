module Reports
  class IncidentsController < ApplicationController
    def index
      @incidents = Incident.includes(:log_report, :created_by, :reviewed_by).recent_first

      if params[:from].present?
        @incidents = @incidents.where("created_at >= ?", params[:from].to_date.beginning_of_day)
      end

      if params[:to].present?
        @incidents = @incidents.where("created_at <= ?", params[:to].to_date.end_of_day)
      end

      if params[:severity].present?
        @incidents = @incidents.where(severity: params[:severity])
      end

      if params[:status].present?
        @incidents = @incidents.where(status: params[:status])
      end

      if params[:incident_type].present?
        @incidents = @incidents.where(incident_type: params[:incident_type])
      end
    end
  end
end