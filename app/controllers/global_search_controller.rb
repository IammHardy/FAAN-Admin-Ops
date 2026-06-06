class GlobalSearchController < ApplicationController
  before_action :authenticate_user!

  MODULES = {
    "all" => "All Modules",
    "records" => "Records",
    "dispatches" => "Dispatches",
    "log_reports" => "Daily Log Reports",
    "monthly_reports" => "Monthly Reports",
    "staff_folders" => "Staff Folders",
    "minutes" => "Minutes",
    "incidents" => "Incidents"
  }.freeze

  def index
    @query = params[:query].to_s.strip
    @date_from = params[:date_from]
    @date_to = params[:date_to]
    @module_filter = params[:module_filter].presence || "all"
    @unit = params[:unit]

    @records = []
    @dispatches = []
    @log_reports = []
    @monthly_reports = []
    @staff_folders = []
    @minutes = []
    @incidents = []

    @units = Unit.active.order(:name)

    return if no_search_params?

    search_records if search_module?("records")
    search_dispatches if search_module?("dispatches")
    search_log_reports if search_module?("log_reports")
    search_monthly_reports if search_module?("monthly_reports")
    search_staff_folders if search_module?("staff_folders")
    search_minutes if search_module?("minutes")
    search_incidents if search_module?("incidents")
  end

  private

  def no_search_params?
    @query.blank? && @date_from.blank? && @date_to.blank? && @unit.blank? && @module_filter == "all"
  end

  def search_module?(module_name)
    @module_filter == "all" || @module_filter == module_name
  end

  def date_range
    return nil if @date_from.blank? && @date_to.blank?

    from = @date_from.present? ? Date.parse(@date_from) : 100.years.ago.to_date
    to = @date_to.present? ? Date.parse(@date_to) : Date.current

    from..to
  rescue ArgumentError
    nil
  end

  def like_query
    "%#{@query}%"
  end

  def search_records
    scope = Record.active.includes(:operation_staff, :filed_by)

    if @query.present?
      scope = scope.where(
        "title ILIKE :q OR category ILIKE :q OR reference_number ILIKE :q OR signed_by ILIKE :q OR recipient_or_source ILIKE :q OR physical_location ILIKE :q",
        q: like_query
      )
    end

    if @unit.present?
      scope = scope.left_joins(:operation_staff)
                   .where("operation_staffs.unit = :unit OR records.physical_location ILIKE :q", unit: @unit, q: "%#{@unit}%")
    end

    scope = scope.where(filed_date: date_range) if date_range

    @records = scope.recent.limit(10)
  end

  def search_dispatches
    scope = Dispatch.includes(:sender_department, :sender_unit, :receiving_department, :receiving_units)

    if @query.present?
      scope = scope.where(
        "dispatches.reference_number ILIKE :q OR dispatches.subject ILIKE :q OR dispatches.delivery_note ILIKE :q OR dispatches.remarks ILIKE :q",
        q: like_query
      )
    end

    if @unit.present?
      scope = scope
        .left_joins(:sender_unit)
        .left_joins(:receiving_units)
        .where("units.name = :unit OR receiving_units_dispatches.name = :unit", unit: @unit)
    end

    scope = scope.where(memo_date: date_range) if date_range

    @dispatches = scope.distinct.recent_first.limit(10)
  end

  def search_log_reports
    scope = LogReport.includes(:department, :unit, :entered_by, :submitted_by)

    if @query.present?
      scope = scope.where(
        "summary ILIKE :q OR general_remarks ILIKE :q",
        q: like_query
      )
    end

    scope = scope.where(unit_id: Unit.find_by(name: @unit)&.id) if @unit.present?
    scope = scope.where(report_date: date_range) if date_range

    @log_reports = scope.recent_first.limit(10)
  end

  def search_monthly_reports
    scope = MonthlyReport.includes(:department, :unit, :uploaded_by)

    if @query.present?
      scope = scope.where(
        "title ILIKE :q OR remarks ILIKE :q",
        q: like_query
      )
    end

    scope = scope.where(unit_id: Unit.find_by(name: @unit)&.id) if @unit.present?
    scope = scope.where(report_month: date_range) if date_range

    @monthly_reports = scope.order(report_month: :desc, created_at: :desc).limit(10)
  end

  def search_staff_folders
    scope = OperationStaff.active_folders

    if @query.present?
      scope = scope.where(
        "full_name ILIKE :q OR staff_number ILIKE :q OR designation ILIKE :q OR unit ILIKE :q OR employment_status ILIKE :q",
        q: like_query
      )
    end

    scope = scope.where(unit: @unit) if @unit.present?

    @staff_folders = scope.order(:full_name).limit(10)
  end

  def search_minutes
    scope = Minute.includes(:created_by)

    if @query.present?
      scope = scope.where(
        "title ILIKE :q OR venue ILIKE :q OR transcript ILIKE :q OR summary ILIKE :q OR action_items ILIKE :q",
        q: like_query
      )
    end

    scope = scope.where(meeting_date: date_range) if date_range

    @minutes = scope.order(created_at: :desc).limit(10)
  end

  def search_incidents
    scope = Incident.includes(:created_by, :reviewed_by)

    if @query.present?
      scope = scope.where(
        "incident_number ILIKE :q OR title ILIKE :q OR description ILIKE :q OR action_taken ILIKE :q OR escalated_to ILIKE :q",
        q: like_query
      )
    end

    scope = scope.where(created_at: date_range) if date_range

    @incidents = scope.recent_first.limit(10)
  end
end