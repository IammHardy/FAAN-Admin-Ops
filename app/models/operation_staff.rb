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

  def self.search(params)
  staff = all

  if params[:query].present?
    q = "%#{params[:query]}%"

    staff = staff.where(
      "full_name ILIKE :q OR staff_number ILIKE :q OR designation ILIKE :q OR unit ILIKE :q",
      q: q
    )
  end

  staff = staff.where(unit: params[:unit]) if params[:unit].present?
  staff = staff.where(designation: params[:designation]) if params[:designation].present?
  staff = staff.where(employment_status: params[:employment_status]) if params[:employment_status].present?
  staff = staff.where(duty_area: params[:duty_area]) if params[:duty_area].present?

  staff
end
end