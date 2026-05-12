class LogEntry < ApplicationRecord
  belongs_to :log_report
  has_one :incident, dependent: :nullify

  validates :description, presence: true

  scope :flagged_as_incident, -> { where(incident_flag: true) }

  before_validation :set_entry_time, on: :create

  def set_entry_time
    self.entry_time ||= Time.current
  end

  def short_description
    description.to_s.truncate(80)
  end
end