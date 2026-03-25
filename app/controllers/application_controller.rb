class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :ensure_user_is_active!

  add_flash_types :success, :error, :warning, :info

  private

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def ensure_user_is_active!
    return unless current_user
    return if current_user.active?

    sign_out current_user
    redirect_to new_user_session_path, alert: "Your account is inactive. Please contact the administrator."
  end
end