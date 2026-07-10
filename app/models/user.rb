class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  belongs_to :department, optional: true
  belongs_to :unit, optional: true

  has_many :notifications, dependent: :destroy
  has_many :duty_sessions, dependent: :destroy

  has_many :created_dispatches,
           class_name: "Dispatch",
           foreign_key: :created_by_id,
           dependent: :nullify

  has_many :dispatched_dispatches,
           class_name: "Dispatch",
           foreign_key: :dispatched_by_id,
           dependent: :nullify

  has_many :submitted_log_reports,
           class_name: "LogReport",
           foreign_key: :submitted_by_id,
           dependent: :nullify

  has_many :entered_log_reports,
           class_name: "LogReport",
           foreign_key: :entered_by_id,
           dependent: :restrict_with_exception

  has_many :created_incidents,
           class_name: "Incident",
           foreign_key: :created_by_id,
           dependent: :restrict_with_exception

  has_many :reviewed_incidents,
           class_name: "Incident",
           foreign_key: :reviewed_by_id,
           dependent: :nullify

  has_many :audit_logs, dependent: :destroy

  enum :role, {
    super_admin: 0,
    admin_officer: 1,
    dispatch_officer: 2,
    unit_officer: 3,
    reviewer: 4
  }

  validates :full_name, presence: true
  validates :role, presence: true

  scope :active, -> { where(active: true) }

  def email_notifications?
  email_notifications_enabled?
end

def sms_notifications?
  sms_notifications_enabled?
end

  def display_name
    full_name.presence || email
  end

  def active_duty_session
    duty_sessions.active.order(started_at: :desc).first
  end

  def duty_session_required?
    requires_duty_session?
  end

  def admin_level?
    super_admin? || admin_officer?
  end

  def can_manage_dispatches?
    super_admin? || admin_officer? || dispatch_officer?
  end

  def can_access_logs?
    super_admin? || admin_officer? || unit_officer? || reviewer?
  end

  def can_access_incidents?
    super_admin? || admin_officer? || reviewer?
  end

  def can_access_reports?
    super_admin? || admin_officer? || reviewer?
  end

  # Name of the administrative unit whose on-duty officers may use the document
  # archive. Kept here as a single source of truth (matches the seeded unit).
  ADMIN_UNIT_NAME = "Airport Admin".freeze

  def in_admin_unit?
    unit&.name == ADMIN_UNIT_NAME
  end

  # Who may view/download the shared document archive (Records). Super admins and
  # admin officers always may; other officers only when they belong to the Admin
  # unit and are currently on duty. Reviewers are explicitly excluded.
  def can_access_records?
    return true if super_admin? || admin_officer?
    return false if reviewer?

    in_admin_unit? && active_duty_session.present?
  end

  def send_devise_notification(notification, *args)
    if notification == :reset_password_instructions
      BrevoEmailService.send_reset_password_email(self, args.first)
    else
      super
    end
  end
end