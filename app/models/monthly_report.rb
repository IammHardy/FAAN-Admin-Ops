class MonthlyReport < ApplicationRecord
  
  belongs_to :department
  belongs_to :unit
  belongs_to :uploaded_by, class_name: "User"
  belongs_to :reviewed_by, class_name: "User", optional: true

  has_one_attached :report_file

  enum :status, {
    draft: 0,
    submitted: 1,
    reviewed: 2,
    archived: 3
  }

  before_validation :set_default_status, on: :create

  validates :title, :report_month, :department, :unit, :uploaded_by, presence: true
  validates :report_file, presence: true


  validate :acceptable_report_file

private
def set_default_status
  self.status ||= :draft
end

def acceptable_report_file
  return unless report_file.attached?

  allowed_types = [
    "application/pdf",
    "application/msword",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "image/png",
    "image/jpeg"
  ]

  unless allowed_types.include?(report_file.content_type)
    errors.add(:report_file, "must be a PDF, DOC, DOCX, PNG, or JPG file")
  end

  if report_file.blob.byte_size > 10.megabytes
    errors.add(:report_file, "must be less than 10MB")
  end
end
end