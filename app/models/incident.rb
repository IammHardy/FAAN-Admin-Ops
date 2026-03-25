class Incident < ApplicationRecord
  belongs_to :log_report
  belongs_to :log_entry
  belongs_to :created_by, class_name: "User"
  belongs_to :reviewed_by, class_name: "User", optional: true
  

  enum :incident_type, {
    operational: 0,
    security: 1,
    safety: 2,
    engineering: 3,
    passenger: 4,
    facility: 5,
    administrative: 6,
    weather: 7,
    other: 8
  }

  enum :severity, {
    low: 0,
    medium: 1,
    high: 2,
    critical: 3
  }

  enum :status, {
    open: 0,
    under_review: 1,
    escalated: 2,
    resolved: 3,
    closed: 4
  }

  validates :incident_number, presence: true, uniqueness: true
  validates :title, presence: true
  validates :description, presence: true
  validates :incident_type, presence: true
  validates :severity, presence: true
  validates :status, presence: true

  before_validation :assign_incident_number, on: :create
  validate :log_entry_should_be_flagged_for_incident, on: :create
  validate :log_entry_must_belong_to_log_report

  scope :open_items, -> { where(status: [:open, :under_review, :escalated]) }
  scope :recent_first, -> { order(created_at: :desc) }

 def review!(reviewer:, remark: nil)
  raise StandardError, "Only open incidents can be marked under review" unless open?

  update!(
    status: :under_review,
    reviewed_by: reviewer,
    reviewer_remark: remark
  )
end

def escalate!(reviewer:, escalated_to:, remark: nil)
  raise StandardError, "Escalation target is required" if escalated_to.blank?
  raise StandardError, "Only open or under-review incidents can be escalated" unless open? || under_review?

  update!(
    status: :escalated,
    escalation_required: true,
    escalated_to: escalated_to,
    escalated_at: Time.current,
    reviewed_by: reviewer,
    reviewer_remark: remark
  )
end

def resolve!(reviewer: nil, remark: nil)
  raise StandardError, "Only under-review or escalated incidents can be resolved" unless under_review? || escalated?

  update!(
    status: :resolved,
    reviewed_by: reviewer || reviewed_by,
    reviewer_remark: remark.presence || reviewer_remark
  )
end

def close!(reviewer: nil, remark: nil)
  raise StandardError, "Only resolved incidents can be closed" unless resolved?

  update!(
    status: :closed,
    reviewed_by: reviewer || reviewed_by,
    reviewer_remark: remark.presence || reviewer_remark
  )
end
  private

  def assign_incident_number
    return if incident_number.present?

    year = Date.current.year
    last_incident = Incident.where("incident_number LIKE ?", "INC-#{year}-%").order(:created_at).last
    next_number =
      if last_incident&.incident_number.present?
        last_incident.incident_number.split("-").last.to_i + 1
      else
        1
      end

    self.incident_number = format("INC-%<year>d-%<number>04d", year: year, number: next_number)
  end

  def log_entry_should_be_flagged_for_incident
    return if log_entry.blank?
    return if log_entry.incident_flag?

    errors.add(:log_entry_id, "must come from a log entry flagged as an incident")
  end

  def log_entry_must_belong_to_log_report
  return if log_entry.blank? || log_report.blank?
  return if log_entry.log_report_id == log_report_id

  errors.add(:log_entry_id, "must belong to the selected log report")
end
end