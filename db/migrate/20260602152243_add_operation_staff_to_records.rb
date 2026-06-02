class AddOperationStaffToRecords < ActiveRecord::Migration[8.0]
  def change
    add_reference :records,
                  :operation_staff,
                  foreign_key: true,
                  null: true
  end
end