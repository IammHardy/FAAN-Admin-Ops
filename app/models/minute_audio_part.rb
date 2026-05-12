class MinuteAudioPart < ApplicationRecord
  belongs_to :minute
  has_one_attached :audio_file

  enum :status, {
    pending: 0,
    processing: 1,
    completed: 2,
    failed: 3
  }

  validates :audio_file, presence: true
  validates :position, presence: true
  validates :status, presence: true
  validate :audio_file_type_and_size

  private

  def audio_file_type_and_size
    return unless audio_file.attached?

    allowed_types = [
      "audio/mpeg",
      "audio/mp3",
      "audio/wav",
      "audio/x-wav",
      "audio/mp4",
      "audio/m4a",
      "audio/webm",
      "audio/ogg"
    ]

    unless allowed_types.include?(audio_file.content_type)
      errors.add(:audio_file, "must be an audio file")
    end

    if audio_file.blob.byte_size > 25.megabytes
      errors.add(:audio_file, "must be less than 25MB per part")
    end
  end
end