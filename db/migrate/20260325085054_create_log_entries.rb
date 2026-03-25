class CreateLogEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :log_entries do |t|
      t.references :log_report, null: false, foreign_key: true
      t.time :entry_time
      t.text :description, null: false
      t.boolean :incident_flag, null: false, default: false
      t.text :action_taken
      t.boolean :follow_up_needed, null: false, default: false

      t.timestamps
    end

    add_index :log_entries, :incident_flag
    add_index :log_entries, :follow_up_needed
  end
end