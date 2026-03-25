class AuditLog < ApplicationRecord
  belongs_to :user
  belongs_to :auditable, polymorphic: true

  validates :action, presence: true
  validates :auditable_type, presence: true
  validates :auditable_id, presence: true

  scope :recent_first, -> { order(created_at: :desc) }

  def auditable_label
    case auditable
    when Dispatch
      auditable.reference_number
    when LogReport
      auditable.display_name
    when Incident
      auditable.incident_number
    when LogEntry
      "Log Entry ##{auditable.id}"
    else
      "#{auditable_type} ##{auditable_id}"
    end
  rescue StandardError
    "#{auditable_type} ##{auditable_id}"
  end
end