class DutySessionsController < ApplicationController
  before_action :authenticate_user!

  def new
    @duty_area = duty_area_for_user

    @today_rosters = DutyRoster
      .active
      .today
      .where(duty_area: @duty_area)
      .includes(:operation_staff)

    if @today_rosters.empty?
      flash.now[:alert] = "No active duty roster has been created for #{@duty_area} today."
    end
  end

  def create
    duty_roster = DutyRoster
      .active
      .today
      .where(duty_area: duty_area_for_user)
      .find(params[:duty_roster_id])

    current_user.duty_sessions.active.update_all(ended_at: Time.current)

    DutySession.create!(
      user: current_user,
      operation_staff: duty_roster.operation_staff,
      duty_roster: duty_roster,
      started_at: Time.current
    )

    redirect_to dashboard_path, notice: "Duty session started successfully."
  rescue ActiveRecord::RecordNotFound
    redirect_to new_duty_session_path,
                alert: "Selected duty roster is not available for your role today."
  end

  def end_current
    current_user.duty_sessions.active.update_all(ended_at: Time.current)

    redirect_to dashboard_path, notice: "Duty session ended."
  end

  private

  def duty_area_for_user
    if current_user.admin_officer? || current_user.dispatch_officer?
      "Admin Office"
    elsif current_user.unit_officer?
      "Unit Office"
    else
      nil
    end
  end
end