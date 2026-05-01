class LogReport < ApplicationRecord
  belongs_to :department
  belongs_to :unit
  belongs_to :submitted_by, class_name: "User", optional: true
  belongs_to :entered_by, class_name: "User"

  has_many :log_entries, dependent: :destroy
  has_many :incidents, dependent: :destroy
  has_one_attached :source_document
  

  accepts_nested_attributes_for :log_entries, allow_destroy: true, reject_if: :all_blank

  enum :shift, {
    morning: 0,
    afternoon: 1,
    night: 2
  }

  enum :status, {
    draft: 0,
    submitted: 1,
    reviewed: 2
  }

  validates :report_date, presence: true
  validates :shift, presence: true
  validates :department, presence: true
  validates :unit, presence: true
  validates :entered_by, presence: true
  validate :unit_belongs_to_department

  scope :recent_first, -> { order(report_date: :desc, created_at: :desc) }

  def submit!
  raise StandardError, "Only draft reports can be submitted" unless draft?
  raise StandardError, "A report must have at least one log entry before submission" if log_entries.empty?

  update!(
  status: :submitted,
  submitted_by: user,
  submitted_at: Time.current
)
end

def review!
  raise StandardError, "Only submitted reports can be reviewed" unless submitted?

  update!(status: :reviewed)
end

   def display_name
  "#{unit.name} - #{report_date.strftime('%d %b %Y')} (#{shift.humanize})"
end


  private


  def unit_belongs_to_department
    return if unit.blank? || department.blank?
    return if unit.department_id == department_id

    errors.add(:unit_id, "must belong to the selected department")
  end
end