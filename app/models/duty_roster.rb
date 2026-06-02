class DutyRoster < ApplicationRecord
  belongs_to :operation_staff
  has_many :duty_sessions, dependent: :destroy

  DUTY_AREAS = [
    "Admin Office",
    "Unit Office"
  ].freeze

  UNIT_SHIFTS = [
    "Morning Shift",
    "Afternoon Shift",
    "Night Shift"
  ].freeze

  validates :operation_staff,
            :duty_date,
            :duty_area,
            presence: true

  validates :duty_area,
            inclusion: { in: DUTY_AREAS }

  validates :shift_name,
            inclusion: { in: UNIT_SHIFTS },
            allow_blank: true

  validate :staff_matches_duty_area
  validate :unit_office_requires_shift

  scope :active, -> { where(active: true) }
  scope :today, -> { where(duty_date: Date.current) }

  private

  def staff_matches_duty_area
    return unless operation_staff.present?

    if operation_staff.duty_area != duty_area
      errors.add(
        :operation_staff,
        "must belong to selected duty area"
      )
    end
  end

  def unit_office_requires_shift
    return unless duty_area == "Unit Office"

    if shift_name.blank?
      errors.add(
        :shift_name,
        "is required for Unit Office duty"
      )
    end
  end
end