class AuditLog < ApplicationRecord
  belongs_to :user
  belongs_to :auditable, polymorphic: true

  validates :action, presence: true
  validates :auditable_type, presence: true
  validates :auditable_id, presence: true
end