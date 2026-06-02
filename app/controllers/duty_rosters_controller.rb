class DutyRostersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_access!
  before_action :set_duty_roster, only: [:edit, :update, :destroy]

  def index
    @duty_rosters = DutyRoster.includes(:operation_staff)
                               .order(duty_date: :desc, created_at: :desc)
                               .page(params[:page])
                               .per(20)
  end

  def new
    @duty_roster = DutyRoster.new(duty_date: Date.current, active: true)
  end

  def create
    @duty_roster = DutyRoster.new(duty_roster_params)

    if @duty_roster.save
      redirect_to duty_rosters_path, notice: "Duty roster created successfully."
    else
      render :new, status: :unprocessable_entity
    end
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