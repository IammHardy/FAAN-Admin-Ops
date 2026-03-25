class AuditLogsController < ApplicationController
  before_action :require_admin_access!

  def index
    @audit_logs = AuditLog.includes(:user).order(created_at: :desc)
  end
end