class DispatchRecipient < ApplicationRecord
  belongs_to :dispatch
  belongs_to :receiving_unit, class_name: "Unit"

  belongs_to :received_by, class_name: "User", optional: true
  belongs_to :acknowledged_by, class_name: "User", optional: true

  enum :status, {
    dispatched: 0,
    received: 1,
    acknowledged: 2,
    filed: 3
  }

  validates :receiving_unit_id, uniqueness: { scope: :dispatch_id }
  scope :recent_first, -> {
  joins(:dispatch).order("dispatches.memo_date DESC, dispatch_recipients.created_at DESC")
}

  def mark_as_received!(receiver_name:, receiver_designation: nil, user:)
    raise StandardError, "This dispatch has already been received" unless dispatched?
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
    raise StandardError, "Only acknowledged dispatches can be filed" unless acknowledged?

    update!(status: :filed)
  end
end