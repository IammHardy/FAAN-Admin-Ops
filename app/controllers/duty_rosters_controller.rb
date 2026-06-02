class DutyRostersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_access!
  before_action :set_duty_roster, only: [:edit, :update, :destroy]

  def index
  @filter = params[:filter].presence || "this_week"

  @duty_rosters = DutyRoster.includes(:operation_staff)

  case @filter
  when "today"
    @duty_rosters = @duty_rosters.where(duty_date: Date.current)
  when "next_week"
    start_date = Date.current.next_week(:monday)
    end_date = start_date.end_of_week(:sunday)
    @duty_rosters = @duty_rosters.where(duty_date: start_date..end_date)
  when "all"
    @duty_rosters = @duty_rosters
  else
    start_date = Date.current.beginning_of_week(:monday)
    end_date = Date.current.end_of_week(:sunday)
    @duty_rosters = @duty_rosters.where(duty_date: start_date..end_date)
  end

  @duty_rosters = @duty_rosters
                    .order(duty_date: :asc, duty_area: :asc, created_at: :asc)
                    .page(params[:page])
                    .per(10)
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
    end
  end

  redirect_to duty_rosters_path,
              notice: "#{created_count} duty roster record(s) created successfully."
end

  def edit
  end

  def update
    if @duty_roster.update(duty_roster_params)
      redirect_to duty_rosters_path, notice: "Duty roster updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @duty_roster.destroy
    redirect_to duty_rosters_path, notice: "Duty roster deleted successfully."
  end

  private

  def set_duty_roster
    @duty_roster = DutyRoster.find(params[:id])
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

  schedule.each do |day_offset, names|
    duty_date = week_start + day_offset.days

    names.each do |name|
      staff = OperationStaff.find_by(full_name: name)
      next unless staff

      DutyRoster.find_or_create_by!(
        operation_staff: staff,
        duty_date: duty_date,
        duty_area: "Admin Office"
      ) do |roster|
        roster.active = true
      end
    end
  end

  redirect_to duty_rosters_path,
              notice: "Admin Office weekly roster generated successfully."
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