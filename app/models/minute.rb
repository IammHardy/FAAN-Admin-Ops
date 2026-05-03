class Minute < ApplicationRecord
  belongs_to :created_by, class_name: "User"

  has_one_attached :audio_file

  enum :status, {
    pending: 0,
    processing: 1,
    completed: 2,
    failed: 3
  }

  validates :title, presence: true
  validates :audio_file, presence: true
end