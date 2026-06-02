class OperationStaff < ApplicationRecord
  has_many :records, dependent: :nullify
  has_many :duty_rosters, dependent: :destroy
  has_many :duty_sessions, dependent: :nullify

  DUTY_AREAS = [
    "Admin Office",
    "Unit Office"
  ].freeze

  validates :full_name, presence: true
  validates :duty_area, inclusion: { in: DUTY_AREAS }, allow_blank: true

  scope :alphabetical, -> { order(:full_name) }
  scope :duty_eligible, -> { where(can_be_on_duty: true).order(:full_name) }
  scope :always_present, -> { where(always_present: true).order(:full_name) }

  scope :for_duty_area, ->(area) {
    where(can_be_on_duty: true, duty_area: area).order(:full_name)
  }

  def display_name
    designation.present? ? "#{full_name} (#{designation})" : full_name
  end
end