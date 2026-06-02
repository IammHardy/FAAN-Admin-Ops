class OperationStaff < ApplicationRecord
  has_many :records, dependent: :nullify

  validates :full_name, presence: true

  scope :alphabetical, -> { order(:full_name) }

  def display_name
    if designation.present?
      "#{full_name} (#{designation})"
    else
      full_name
    end
  end
end