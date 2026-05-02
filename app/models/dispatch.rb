class Dispatch < ApplicationRecord
  belongs_to :sender_department, class_name: "Department"
  belongs_to :sender_unit, class_name: "Unit", optional: true
  belongs_to :receiving_department, class_name: "Department"
  belongs_to :receiving_unit, class_name: "Unit", optional: true
  belongs_to :received_by, class_name: "User", optional: true
  belongs_to :acknowledged_by, class_name: "User", optional: true

  belongs_to :created_by, class_name: "User"
  belongs_to :dispatched_by, class_name: "User", optional: true
  has_one_attached :memo_file
  has_many :dispatch_recipients, dependent: :destroy
  has_many :receiving_units, through: :dispatch_recipients

  enum :status, {
    draft: 0,
    dispatched: 1,
    received: 2,
    acknowledged: 3,
    filed: 4
  }

  validates :reference_number, presence: true, uniqueness: true
  validates :subject, presence: true
  validates :memo_date, presence: true
  validates :sender_department, presence: true
  validates :receiving_department, presence: true
  # validate :sender_and_receiver_departments_must_differ

  before_validation :assign_reference_number, on: :create

  scope :recent_first, -> { order(memo_date: :desc, created_at: :desc) }
  scope :pending, -> { where(status: [:draft, :dispatched]) }

  def mark_as_dispatched!(user)
  raise StandardError, "Only draft dispatches can be marked as dispatched" unless draft?

  update!(
    status: :dispatched,
    dispatched_by: user,
    dispatched_at: Time.current
  )
end

def mark_as_received!(receiver_name:, receiver_designation: nil, user:)
  raise StandardError, "Dispatch must be dispatched first" unless dispatched?
  raise StandardError, "Receiver name is required" if receiver_name.blank?

  update!(
    status: :received,
    receiver_name: receiver_name,
    receiver_designation: receiver_designation,
    received_by: user,
    received_at: Time.current
  )
end

def mark_as_acknowledged!(user:, note: nil)
  raise StandardError, "Only received dispatches can be acknowledged" unless received?

  update!(
    status: :acknowledged,
    acknowledged_by: user,
    acknowledged_at: Time.current,
    acknowledgement_note: note
  )
end

def mark_as_filed!
  raise StandardError, "All recipient units must acknowledge before filing" unless all_recipients_acknowledged?

  dispatch_recipients.find_each(&:mark_as_filed!)
  update!(status: :filed)
end

def all_recipients_acknowledged?
  dispatch_recipients.any? && dispatch_recipients.all?(&:acknowledged?)
end

  private

  # def sender_and_receiver_departments_must_differ
  #   return if sender_department_id.blank? || receiving_department_id.blank?
  #   return unless sender_department_id == receiving_department_id

  #   errors.add(:receiving_department_id, "must be different from sender department")
  # end

  def assign_reference_number
    return if reference_number.present?

    year = Date.current.year
    last_dispatch = Dispatch.where("reference_number LIKE ?", "DPT-#{year}-%").order(:created_at).last
    next_number =
      if last_dispatch&.reference_number.present?
        last_dispatch.reference_number.split("-").last.to_i + 1
      else
        1
      end

    self.reference_number = format("DPT-%<year>d-%<number>04d", year: year, number: next_number)
  end
end