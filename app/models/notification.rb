class Notification < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :message, presence: true

  scope :unread, -> { where(read: false) }
  scope :recent_first, -> { order(created_at: :desc) }

  def mark_as_read!
    update!(read: true)
  end
end