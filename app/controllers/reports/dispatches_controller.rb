module Reports
  class DispatchesController < ApplicationController
    before_action :require_report_access!
    def index
      @dispatches = Dispatch.includes(:sender_department, :receiving_department, :created_by).recent_first

      if params[:from].present?
        @dispatches = @dispatches.where("memo_date >= ?", params[:from])
      end

      if params[:to].present?
        @dispatches = @dispatches.where("memo_date <= ?", params[:to])
      end

      if params[:status].present?
        @dispatches = @dispatches.where(status: params[:status])
      end
    end
  end
end