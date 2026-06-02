class DutySession < ApplicationRecord
  belongs_to :user
  belongs_to :operation_staff
  belongs_to :duty_roster

  validates :started_at, presence: true

  scope :active, -> { where(ended_at: nil) }

  def active?
    ended_at.nil?
  end
end