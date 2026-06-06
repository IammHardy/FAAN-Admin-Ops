class Record < ApplicationRecord
  belongs_to :filed_by, class_name: "User"
  belongs_to :operation_staff, optional: true
  belongs_to :duty_session, optional: true

  has_one_attached :attachment

  belongs_to :deleted_by, class_name: "User", optional: true

scope :active, -> { where(deleted_at: nil) }
scope :deleted, -> { where.not(deleted_at: nil) }

def deleted?
  deleted_at.present?
end

def soft_delete!(user)
  update!(deleted_at: Time.current, deleted_by: user)
end

def restore!
  update!(deleted_at: nil, deleted_by: nil, restore_note: nil)
end

  GENERAL_CATEGORIES = [
    "Dispatch Copy",
    "Internal Memo",
    "Nominal Roll",
    "Monthly Report",
    "Minutes of Meeting",
    "Staff Deployment",
    "NYSC/IT Deployment",
    "Ministry Correspondence",
    "Other General Record"
  ].freeze

  STAFF_DOCUMENT_TYPES = [
    "Employment Letter",
    "Leave Letter",
    "Promotion Letter",
    "Deployment Letter",
    "Posting Letter",
    "NYSC Posting Letter",
    "NYSC Acceptance Letter",
    "NYSC Clearance",
    "IT Placement Letter",
    "IT Acceptance Letter",
    "IT Completion Letter",
    "Final Clearance",
    "Query Letter",
    "Reply to Query",
    "Training Letter",
    "Medical Document",
    "Appointment Letter",
    "Confirmation Letter",
    "Disciplinary Document",
    "Retirement Document",
    "Other Staff Document"
  ].freeze

  CATEGORIES = (GENERAL_CATEGORIES + STAFF_DOCUMENT_TYPES).uniq.freeze

  validates :title, :category, :filed_date, :physical_location, presence: true
  validates :category, inclusion: { in: CATEGORIES }

  validate :staff_document_must_have_operation_staff
  validate :acceptable_attachment

  scope :recent, -> { order(filed_date: :desc, created_at: :desc) }

  def self.search(params)
    records = all

    if params[:query].present?
      q = "%#{params[:query]}%"
      records = records.where(
        "title ILIKE :q OR recipient_or_source ILIKE :q OR reference_number ILIKE :q OR signed_by ILIKE :q OR physical_location ILIKE :q",
        q: q
      )
    end

    records = records.where(category: params[:category]) if params[:category].present?
    records = records.where(filed_date: params[:filed_date]) if params[:filed_date].present?
    records = records.where(document_date: params[:document_date]) if params[:document_date].present?
    records = records.where(operation_staff_id: params[:operation_staff_id]) if params[:operation_staff_id].present?

    records
  end

  def staff_document?
    STAFF_DOCUMENT_TYPES.include?(category)
  end

  def general_record?
    GENERAL_CATEGORIES.include?(category)
  end

  private

  def staff_document_must_have_operation_staff
    return unless staff_document?
    return if operation_staff_id.present?

    errors.add(:operation_staff, "must be selected for staff folder documents")
  end

  def acceptable_attachment
    return unless attachment.attached?

    allowed_types = [
      "application/pdf",
      "image/png",
      "image/jpeg",
      "application/msword",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    ]

    unless allowed_types.include?(attachment.content_type)
      errors.add(
        :attachment,
        "must be PDF, Word document, PNG, or JPG"
      )
    end

    if attachment.blob.byte_size > 15.megabytes
      errors.add(
        :attachment,
        "must be smaller than 15MB"
      )
    end
  end
end