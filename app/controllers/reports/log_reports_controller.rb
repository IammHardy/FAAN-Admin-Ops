require "csv"
require "prawn"
module Reports
  class LogReportsController < ApplicationController
    

    before_action :require_report_access!

    def index
      @log_reports = filtered_log_reports
      .page(params[:page]).per(15)
    end

    def export_csv
      @log_reports = filtered_log_reports

      csv_data = CSV.generate(headers: true) do |csv|
        csv << [
          "Date",
          "Shift",
          "Department",
          "Unit",
          "Status",
          "Entered By",
          "Submitted By",
          "Submitted At"
        ]

        @log_reports.each do |report|
          csv << [
            report.report_date&.strftime("%d %b %Y"),
            report.shift&.humanize,
            report.department&.name,
            report.unit&.name,
            report.status&.humanize,
            report.entered_by&.display_name,
            report.submitted_by&.display_name,
            report.submitted_at&.strftime("%d %b %Y, %I:%M %p")
          ]
        end
      end

      send_data csv_data,
                filename: "log_reports_#{Date.current}.csv",
                type: "text/csv"
    end
    def export_pdf
  @log_reports = filtered_log_reports

  pdf = Prawn::Document.new

  pdf.text "FAAN Log Reports", size: 18, style: :bold
  pdf.move_down 10
  pdf.text "Generated on: #{Time.current.strftime('%d %b %Y, %I:%M %p')}", size: 10
  pdf.move_down 20

  @log_reports.each do |report|
    pdf.text "Date: #{report.report_date&.strftime('%d %b %Y')}", style: :bold
    pdf.text "Shift: #{report.shift&.humanize}"
    pdf.text "Department: #{report.department&.name}"
    pdf.text "Unit: #{report.unit&.name}"
    pdf.text "Status: #{report.status&.humanize}"
    pdf.text "Entered By: #{report.entered_by&.display_name || '-'}"
    pdf.text "Submitted By: #{report.submitted_by&.display_name || '-'}"
    pdf.text "Submitted At: #{report.submitted_at&.strftime('%d %b %Y, %I:%M %p') || '-'}"
    pdf.move_down 10
    pdf.stroke_horizontal_rule
    pdf.move_down 10
  end

  send_data pdf.render,
            filename: "log_reports_#{Date.current}.pdf",
            type: "application/pdf",
            disposition: "attachment"
end

    private

    def filtered_log_reports
      reports = LogReport.includes(:department, :unit, :entered_by, :submitted_by).recent_first

      reports = reports.where("report_date >= ?", params[:from]) if params[:from].present?
      reports = reports.where("report_date <= ?", params[:to]) if params[:to].present?
      reports = reports.where(department_id: params[:department_id]) if params[:department_id].present?
      reports = reports.where(unit_id: params[:unit_id]) if params[:unit_id].present?

      reports
    end
  end
end