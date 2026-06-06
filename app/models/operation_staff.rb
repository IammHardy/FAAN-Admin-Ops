class OperationStaff < ApplicationRecord
  has_many :records, dependent: :nullify
  has_many :duty_rosters, dependent: :destroy
  has_many :duty_sessions, dependent: :nullify


  belongs_to :archived_by, class_name: "User", optional: true

FOLDER_STATUSES = {
  active: "active",
  on_leave: "on_leave",
  transferred: "transferred",
  retired: "retired",
  completed_service: "completed_service",
  archived: "archived"
}.freeze

scope :active_folders, -> { where(folder_status: "active") }
scope :archived_folders, -> { where.not(folder_status: "active") }

def archive!(user, reason: nil, status: "archived")
  update!(
    folder_status: status,
    archived_at: Time.current,
    archived_by: user,
    archive_reason: reason
  )
end

def restore!
  update!(
    folder_status: "active",
    archived_at: nil,
    archived_by: nil,
    archive_reason: nil
  )
end

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