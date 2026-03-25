class Unit < ApplicationRecord
  belongs_to :department

  has_many :users, dependent: :nullify
  has_many :log_reports, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { scope: :department_id }

  scope :active, -> { where(active: true) }

  def full_name
    "#{department.name} - #{name}"
  end
end