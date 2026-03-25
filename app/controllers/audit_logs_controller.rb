class AuditLogsController < ApplicationController
  before_action :require_admin_access!

  def index
    @audit_logs = AuditLog.includes(:user).order(created_at: :desc)

    if params[:user].present?
      @audit_logs = @audit_logs.joins(:user).where(
        "users.full_name ILIKE :q OR users.email ILIKE :q",
        q: "%#{params[:user]}%"
      )
    end

    if params[:audit_action].present?
      @audit_logs = @audit_logs.where("action ILIKE ?", "%#{params[:audit_action]}%")
    end

    if params[:record_type].present?
      @audit_logs = @audit_logs.where("auditable_type ILIKE ?", "%#{params[:record_type]}%")
    end
  end
end