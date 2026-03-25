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

  scope :open_items, -> { where(status: [:open, :under_review, :escalated]) }
  scope :recent_first, -> { order(created_at: :desc) }

  def review!(reviewer:, remark: nil)
    update!(
      status: :under_review,
      reviewed_by: reviewer,
      reviewer_remark: remark
    )
  end

  def escalate!(reviewer:, escalated_to:, remark: nil)
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
    update!(
      status: :resolved,
      reviewed_by: reviewer || reviewed_by,
      reviewer_remark: remark.presence || reviewer_remark
    )
  end

  def close!(reviewer: nil, remark: nil)
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
end