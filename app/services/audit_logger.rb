class AuditLogger
  def self.call(user:, action:, auditable:, description:)
    return if user.blank? || auditable.blank?

    AuditLog.create!(
      user: user,
      action: action,
      auditable: auditable,
      description: description
    )
  rescue StandardError => e
    Rails.logger.error("Audit log failed: #{e.message}")
  end
end