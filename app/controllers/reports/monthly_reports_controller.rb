module Reports
  class MonthlyReportsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_monthly_report,
                  only: [:show, :edit, :update, :destroy, :submit, :review, :archive]

    def index
      @monthly_reports =
        if current_user.unit_officer?
          MonthlyReport.includes(:department, :unit, :uploaded_by)
                       .where(unit: current_user.unit)
                       .order(report_month: :desc, created_at: :desc)

        elsif current_user.reviewer?
          MonthlyReport.includes(:department, :unit, :uploaded_by)
                       .where(status: [:submitted, :reviewed])
                       .order(report_month: :desc, created_at: :desc)

        else
          MonthlyReport.includes(:department, :unit, :uploaded_by)
                       .order(report_month: :desc, created_at: :desc)
        end
    end

    def show
    end

    def new
      @monthly_report = MonthlyReport.new
      load_form_data
    end

    def create
      @monthly_report = MonthlyReport.new(monthly_report_params)
      @monthly_report.uploaded_by = current_user

      if current_user.unit_officer?
        @monthly_report.department = current_user.department
        @monthly_report.unit = current_user.unit
      end

      if @monthly_report.save
        redirect_to reports_monthly_report_path(@monthly_report),
                    notice: "Monthly report uploaded successfully."
      else
        load_form_data
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      load_form_data
    end

    def update
      if @monthly_report.update(monthly_report_params)
        redirect_to reports_monthly_report_path(@monthly_report),
                    notice: "Monthly report updated successfully."
      else
        load_form_data
        render :edit, status: :unprocessable_entity
      end
    end

    def submit
      @monthly_report.update!(status: :submitted)

      redirect_to reports_monthly_report_path(@monthly_report),
                  notice: "Monthly report submitted successfully."
    end

    def review
      @monthly_report.update!(
        status: :reviewed,
        reviewed_by: current_user,
        reviewed_at: Time.current
      )

      redirect_to reports_monthly_report_path(@monthly_report),
                  notice: "Monthly report reviewed successfully."
    end

    def archive
      @monthly_report.update!(status: :archived)

      redirect_to reports_monthly_report_path(@monthly_report),
                  notice: "Monthly report archived successfully."
    end

    def destroy
      @monthly_report.destroy

      redirect_to reports_monthly_reports_path,
                  notice: "Monthly report deleted successfully."
    end

    private

    def set_monthly_report
      @monthly_report = MonthlyReport.find(params[:id])
    end

    def load_form_data
      @departments = Department.order(:name)
      @units = Unit.includes(:department).order(:name)
    end

    def monthly_report_params
      params.require(:monthly_report).permit(
        :title,
        :report_month,
        :department_id,
        :unit_id,
        :remarks,
        :report_file
      )
    end
  end
end