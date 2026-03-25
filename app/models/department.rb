class Department < ApplicationRecord
  has_many :units, dependent: :destroy
  has_many :users, dependent: :nullify

  has_many :sent_dispatches, class_name: "Dispatch", foreign_key: :sender_department_id, dependent: :restrict_with_exception
  has_many :received_dispatches, class_name: "Dispatch", foreign_key: :receiving_department_id, dependent: :restrict_with_exception

  has_many :log_reports, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
end