class LogReportsController < ApplicationController
  before_action :set_log_report, only: [:show, :edit, :update, :destroy, :submit_report, :review, :print]
  before_action :load_log_report_form_collections, only: [:new, :create, :edit, :update]

  def index
    @log_reports = LogReport.includes(:department, :unit, :entered_by).recent_first
  end

  def show
    @log_entries = @log_report.log_entries.order(:entry_time)
    @incidents = @log_report.incidents.recent_first
  end

  def new
    @log_report = LogReport.new(report_date: Date.current, entered_by: current_user)
    @log_report.log_entries.build
  end

  def create
    @log_report = LogReport.new(log_report_params)
    @log_report.entered_by = current_user

    if @log_report.save
      redirect_to @log_report, success: "Log report created successfully."
    else
      flash.now[:error] = "Unable to create log report."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @log_report.log_entries.build if @log_report.log_entries.empty?
  end

  def update
    if @log_report.update(log_report_params)
      redirect_to @log_report, success: "Log report updated successfully."
    else
      flash.now[:error] = "Unable to update log report."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @log_report.destroy
    redirect_to log_reports_path, success: "Log report deleted successfully."
  end

  def submit_report
    @log_report.submit!
    redirect_to @log_report, success: "Log report submitted successfully."
  rescue StandardError => e
    redirect_to @log_report, error: e.message
  end

  def review
    @log_report.review!
    redirect_to @log_report, success: "Log report reviewed successfully."
  rescue StandardError => e
    redirect_to @log_report, error: e.message
  end

  def print
    @log_entries = @log_report.log_entries.order(:entry_time)
    render layout: "print"
  end

  private

  def set_log_report
    @log_report = LogReport.find(params[:id])
  end

  def load_log_report_form_collections
    @departments = Department.active.order(:name)
    @units = Unit.active.includes(:department).order(:name)
  end

  def log_report_params
    params.require(:log_report).permit(
      :report_date,
      :shift,
      :department_id,
      :unit_id,
      :summary,
      :general_remarks,
      :status,
      :submitted_by_id,
      log_entries_attributes: [
        :id,
        :entry_time,
        :description,
        :incident_flag,
        :action_taken,
        :follow_up_needed,
        :_destroy
      ]
    )
  end
end