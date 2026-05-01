require "csv"

module Reports
  class IncidentsController < ApplicationController
    before_action :require_report_access!

    def index
      @incidents = filtered_incidents
    end

    def export_csv
      @incidents = filtered_incidents

      csv_data = CSV.generate(headers: true) do |csv|
        csv << [
          "Incident No",
          "Title",
          "Type",
          "Severity",
          "Status",
          "Created By",
          "Reviewed By",
          "Created At"
        ]

        @incidents.each do |incident|
          csv << [
            incident.incident_number,
            incident.title,
            incident.incident_type.humanize,
            incident.severity.humanize,
            incident.status.humanize,
            incident.created_by&.display_name,
            incident.reviewed_by&.display_name,
            incident.created_at.strftime("%d %b %Y, %I:%M %p")
          ]
        end
      end

      send_data csv_data,
                filename: "incidents_#{Date.current}.csv",
                type: "text/csv"
    end

    def export_pdf
  @incidents = filtered_incidents

  pdf = Prawn::Document.new

  pdf.text "FAAN Incident Reports", size: 18, style: :bold
  pdf.move_down 10
  pdf.text "Generated on: #{Time.current.strftime('%d %b %Y, %I:%M %p')}", size: 10
  pdf.move_down 20

  @incidents.each do |incident|
    pdf.text "Incident No: #{incident.incident_number}", style: :bold
    pdf.text "Title: #{incident.title}"
    pdf.text "Type: #{incident.incident_type&.humanize}"
    pdf.text "Severity: #{incident.severity&.humanize}"
    pdf.text "Status: #{incident.status&.humanize}"
    pdf.text "Created By: #{incident.created_by&.display_name || '-'}"
    pdf.text "Reviewed By: #{incident.reviewed_by&.display_name || '-'}"
    pdf.text "Created At: #{incident.created_at.strftime('%d %b %Y, %I:%M %p')}"
    pdf.move_down 10
    pdf.stroke_horizontal_rule
    pdf.move_down 10
  end

  send_data pdf.render,
            filename: "incidents_#{Date.current}.pdf",
            type: "application/pdf",
            disposition: "attachment"
end

    private

    def filtered_incidents
      incidents = Incident.includes(:created_by, :reviewed_by).recent_first

      incidents = incidents.where("created_at >= ?", params[:from]) if params[:from].present?
      incidents = incidents.where("created_at <= ?", params[:to]) if params[:to].present?
      incidents = incidents.where(severity: params[:severity]) if params[:severity].present?
      incidents = incidents.where(status: params[:status]) if params[:status].present?
      incidents = incidents.where(incident_type: params[:incident_type]) if params[:incident_type].present?

      incidents
    end
  end
end