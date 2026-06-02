class AddStaffToRecords < ActiveRecord::Migration[8.0]
  def change
    add_reference :records,
                  :staff,
                  null: true,
                  foreign_key: { to_table: :users }
  end
end