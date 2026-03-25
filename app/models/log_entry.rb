class LogEntry < ApplicationRecord
  belongs_to :log_report
  has_one :incident, dependent: :nullify

  validates :description, presence: true

  scope :flagged_as_incident, -> { where(incident_flag: true) }

  def short_description
  description.to_s.truncate(80)
end
end