class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  belongs_to :department, optional: true
  belongs_to :unit, optional: true

  has_many :created_dispatches, class_name: "Dispatch", foreign_key: :created_by_id, dependent: :nullify
  has_many :dispatched_dispatches, class_name: "Dispatch", foreign_key: :dispatched_by_id, dependent: :nullify

  has_many :submitted_log_reports, class_name: "LogReport", foreign_key: :submitted_by_id, dependent: :nullify
  has_many :entered_log_reports, class_name: "LogReport", foreign_key: :entered_by_id, dependent: :restrict_with_exception

  has_many :created_incidents, class_name: "Incident", foreign_key: :created_by_id, dependent: :restrict_with_exception
  has_many :reviewed_incidents, class_name: "Incident", foreign_key: :reviewed_by_id, dependent: :nullify

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

  def display_name
    full_name.presence || email
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
end