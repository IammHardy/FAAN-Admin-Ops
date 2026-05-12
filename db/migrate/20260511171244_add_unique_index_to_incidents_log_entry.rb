class AddUniqueIndexToIncidentsLogEntry < ActiveRecord::Migration[8.0]
  def change
    add_index :incidents,
              :log_entry_id,
              unique: true,
              name: "index_incidents_on_unique_log_entry"
  end
end