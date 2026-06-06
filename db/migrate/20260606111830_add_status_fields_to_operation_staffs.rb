class AddStatusFieldsToOperationStaffs < ActiveRecord::Migration[8.0]
  def change
    add_column :operation_staffs, :folder_status, :string, default: "active", null: false
    add_column :operation_staffs, :archived_at, :datetime
    add_column :operation_staffs, :archive_reason, :text

    add_reference :operation_staffs,
                  :archived_by,
                  null: true,
                  foreign_key: { to_table: :users }

    add_index :operation_staffs, :folder_status
    add_index :operation_staffs, :archived_at
  end
end