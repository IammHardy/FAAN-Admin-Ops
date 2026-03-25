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

  def require_super_admin!
    return if current_user&.super_admin?

    redirect_to dashboard_path, error: "You are not authorized to perform this action."
  end

  def require_admin_access!
    return if current_user&.super_admin? || current_user&.admin_officer?

    redirect_to dashboard_path, error: "You are not authorized to perform this action."
  end

  def require_dispatch_access!
    return if current_user&.super_admin? || current_user&.admin_officer? || current_user&.dispatch_officer?

    redirect_to dashboard_path, error: "You are not authorized to perform this action."
  end

  def require_log_access!
    return if current_user&.super_admin? || current_user&.admin_officer? || current_user&.unit_officer? || current_user&.reviewer?

    redirect_to dashboard_path, error: "You are not authorized to perform this action."
  end

  def require_incident_access!
    return if current_user&.super_admin? || current_user&.admin_officer? || current_user&.reviewer?

    redirect_to dashboard_path, error: "You are not authorized to perform this action."
  end

  def require_report_access!
    return if current_user&.super_admin? || current_user&.admin_officer? || current_user&.reviewer?

    redirect_to dashboard_path, error: "You are not authorized to perform this action."
  end

  def require_same_unit_or_admin!(record_unit)
    return if current_user&.super_admin? || current_user&.admin_officer?
    return if current_user&.unit_officer? && current_user.unit_id == record_unit.id

    redirect_to dashboard_path, error: "You are not authorized to access this record."
  end

  def require_reviewer_or_admin!
    return if current_user&.super_admin? || current_user&.admin_officer? || current_user&.reviewer?

    redirect_to dashboard_path, error: "You are not authorized to perform this action."
  end
end