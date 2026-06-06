class AddDeletedFieldsToRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :records, :deleted_at, :datetime
    add_column :records, :restore_note, :text

    add_reference :records,
                  :deleted_by,
                  null: true,
                  foreign_key: { to_table: :users }

    add_index :records, :deleted_at
  end
end