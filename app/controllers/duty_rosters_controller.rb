class DutyRostersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_super_admin!
  before_action :set_duty_roster, only: [:edit, :update, :destroy]

  def index
    @filter = params[:filter].presence || "this_week"

    scope = DutyRoster.includes(:operation_staff)

    case @filter
    when "today"
      scope = scope.where(duty_date: Date.current)
    when "next_week"
      start_date = Date.current.next_week(:monday)
      end_date = start_date.end_of_week(:sunday)
      scope = scope.where(duty_date: start_date..end_date)
    when "all"
      scope = scope
    else
      start_date = Date.current.beginning_of_week(:monday)
      end_date = Date.current.end_of_week(:sunday)
      scope = scope.where(duty_date: start_date..end_date)
    end

    scope = scope.order(
      duty_date: :asc,
      duty_area: :asc,
      created_at: :asc
    )

    if @filter == "all"
      @duty_rosters = scope.page(params[:page]).per(30)
      @grouped_duty_rosters = @duty_rosters.group_by(&:duty_date)
    else
      @duty_rosters = scope
      @grouped_duty_rosters = @duty_rosters.group_by(&:duty_date)
    end
  end

  def new
    @duty_roster = DutyRoster.new(duty_date: Date.current, active: true)
  end

  def create
    staff_ids = params.dig(:duty_roster, :operation_staff_ids)&.reject(&:blank?) || []

    if staff_ids.empty?
      @duty_roster = DutyRoster.new(duty_roster_params)
      @duty_roster.errors.add(:operation_staff, "must select at least one staff")
      return render :new, status: :unprocessable_entity
    end

    created_count = 0

    staff_ids.each do |staff_id|
      duty_roster = DutyRoster.find_or_initialize_by(
        operation_staff_id: staff_id,
        duty_date: duty_roster_params[:duty_date],
        duty_area: duty_roster_params[:duty_area]
      )

      duty_roster.shift_name = duty_roster_params[:shift_name]
      duty_roster.active = duty_roster_params[:active]

      if duty_roster.save
        created_count += 1

        AuditLogger.call(
          user: current_user,
          action: "create",
          auditable: duty_roster,
          description: "Created duty roster for #{duty_roster.operation_staff.full_name} on #{duty_roster.duty_date}"
        )
      end
    end

    redirect_to duty_rosters_path,
                notice: "#{created_count} duty roster record(s) created successfully."
  end

  def edit
  end

  def update
    if @duty_roster.update(duty_roster_params)
      AuditLogger.call(
        user: current_user,
        action: "update",
        auditable: @duty_roster,
        description: "Updated duty roster for #{@duty_roster.operation_staff.full_name} on #{@duty_roster.duty_date}"
      )

      redirect_to duty_rosters_path, notice: "Duty roster updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    staff_name = @duty_roster.operation_staff.full_name
    duty_date = @duty_roster.duty_date

    if @duty_roster.destroy
      AuditLogger.call(
        user: current_user,
        action: "delete",
        auditable: nil,
        description: "Deleted duty roster for #{staff_name} on #{duty_date}"
      )

      redirect_to duty_rosters_path, notice: "Duty roster deleted successfully."
    else
      redirect_to duty_rosters_path, alert: "Duty roster could not be deleted."
    end
  end

  def generate_admin_week
    week_start = Date.parse(params[:week_start])

    schedule = {
      0 => [
        "Miss Bilkisu Ashara",
        "Mrs Rabia Maikudi",
        "Mrs Rukaya Zakari",
        "Mrs Sudai Gambo",
        "Madam Precious",
        "Mrs Hadiza",
        "Yusuf Abdulhadi Adavize"
      ],
      1 => [
        "Chinecherem Evelyn",
        "Miss Bilkisu Ashara",
        "Mrs Sudai Gambo",
        "Mrs Hadiza"
      ],
      2 => [
        "Mrs Rabia Maikudi",
        "Mrs Rukaya Zakari",
        "Madam Precious",
        "Mrs Hadiza"
      ],
      3 => [
        "Yusuf Abdulhadi Adavize",
        "Mrs Rabia Maikudi",
        "Mrs Rukaya Zakari",
        "Madam Precious"
      ],
      4 => [
        "Yusuf Abdulhadi Adavize",
        "Chinecherem Evelyn",
        "Miss Bilkisu Ashara",
        "Mrs Sudai Gambo"
      ]
    }

    created_count = 0
    skipped_count = 0

    schedule.each do |day_offset, names|
      duty_date = week_start + day_offset.days

      names.each do |name|
        staff = OperationStaff.find_by(full_name: name)

        unless staff
          skipped_count += 1
          next
        end

        roster = DutyRoster.find_or_initialize_by(
          operation_staff: staff,
          duty_date: duty_date,
          duty_area: "Admin Office"
        )

        if roster.new_record?
          roster.active = true
          roster.save!
          created_count += 1
        else
          skipped_count += 1
        end
      end
    end

    AuditLogger.call(
      user: current_user,
      action: "generate",
      auditable: nil,
      description: "Generated Admin Office weekly duty roster from #{week_start}. Created #{created_count}, skipped #{skipped_count}."
    )

    redirect_to duty_rosters_path(filter: "next_week"),
                notice: "#{created_count} roster record(s) generated. #{skipped_count} skipped."
  rescue ArgumentError
    redirect_to duty_rosters_path,
                alert: "Please select a valid week start date."
  end

  private

  def set_duty_roster
    @duty_roster = DutyRoster.find(params[:id])
  end

  def duty_roster_params
    params.require(:duty_roster).permit(
      :operation_staff_id,
      :duty_date,
      :duty_area,
      :shift_name,
      :active
    )
  end
end