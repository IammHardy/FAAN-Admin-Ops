class DutySessionsController < ApplicationController
  before_action :authenticate_user!

  def new
   duty_area =
  if current_user.admin_officer? || current_user.dispatch_officer?
    "Admin Office"
  elsif current_user.unit_officer?
    "Unit Office"
  end

@today_rosters =
  DutyRoster.active
            .today
            .where(duty_area: duty_area)
            .includes(:operation_staff)
  end

  def create
    duty_roster = DutyRoster.active.today.find(params[:duty_roster_id])

    current_user.duty_sessions.active.update_all(ended_at: Time.current)

    DutySession.create!(
      user: current_user,
      operation_staff: duty_roster.operation_staff,
      duty_roster: duty_roster,
      started_at: Time.current
    )

    redirect_to dashboard_path, notice: "Duty session started successfully."
  end

  def end_current
    current_user.duty_sessions.active.update_all(ended_at: Time.current)

    redirect_to dashboard_path, notice: "Duty session ended."
  end
end