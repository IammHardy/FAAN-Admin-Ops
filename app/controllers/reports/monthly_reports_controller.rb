module Reports
  class MonthlyReportsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_active_duty_session!,
                  only: [:new, :create, :edit, :update, :destroy, :submit]

    before_action :set_monthly_report,
                  only: [:show, :edit, :update, :destroy, :submit, :review, :archive, :download_report_file]

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
      @monthly_report.duty_session = current_duty_session

      if current_user.unit_officer?
        @monthly_report.department = current_user.department
        @monthly_report.unit = current_user.unit
      end

      if @monthly_report.save
        AuditLogger.call(
          user: current_user,
          action: "create",
          auditable: @monthly_report,
          description: "Created monthly report #{@monthly_report.title}"
        )

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
        AuditLogger.call(
          user: current_user,
          action: "update",
          auditable: @monthly_report,
          description: "Updated monthly report #{@monthly_report.title}"
        )

        redirect_to reports_monthly_report_path(@monthly_report),
                    notice: "Monthly report updated successfully."
      else
        load_form_data
        render :edit, status: :unprocessable_entity
      end
    end

    def submit
      @monthly_report.update!(status: :submitted)
      NotificationService.monthly_report_submitted(@monthly_report)

      AuditLogger.call(
        user: current_user,
        action: "submit",
        auditable: @monthly_report,
        description: "Submitted monthly report #{@monthly_report.title}"
      )

      redirect_to reports_monthly_report_path(@monthly_report),
                  notice: "Monthly report submitted successfully."
    end

    def review
      @monthly_report.update!(
        status: :reviewed,
        reviewed_by: current_user,
        reviewed_at: Time.current
      )

      AuditLogger.call(
        user: current_user,
        action: "review",
        auditable: @monthly_report,
        description: "Reviewed monthly report #{@monthly_report.title}"
      )

      redirect_to reports_monthly_report_path(@monthly_report),
                  notice: "Monthly report reviewed successfully."
    end

    def archive
      @monthly_report.update!(status: :archived)

      AuditLogger.call(
        user: current_user,
        action: "archive",
        auditable: @monthly_report,
        description: "Archived monthly report #{@monthly_report.title}"
      )

      redirect_to reports_monthly_report_path(@monthly_report),
                  notice: "Monthly report archived successfully."
    end

    def destroy
      report_title = @monthly_report.title

      if @monthly_report.destroy
        AuditLogger.call(
          user: current_user,
          action: "delete",
          auditable: nil,
          description: "Deleted monthly report #{report_title}"
        )

        redirect_to reports_monthly_reports_path,
                    notice: "Monthly report deleted successfully."
      else
        redirect_to reports_monthly_report_path(@monthly_report),
                    alert: "Monthly report could not be deleted."
      end
    end

    def download_report_file
  unless @monthly_report.report_file.attached?
    redirect_to reports_monthly_report_path(@monthly_report),
                alert: "No report file found."
    return
  end

  redirect_to rails_storage_proxy_path(
  @monthly_report.report_file,
  disposition: "attachment"
)
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