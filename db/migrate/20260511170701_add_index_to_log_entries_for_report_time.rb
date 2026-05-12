class AddIndexToLogEntriesForReportTime < ActiveRecord::Migration[8.0]
  def change
    add_index :log_entries,
              [:log_report_id, :entry_time],
              name: "index_log_entries_on_report_and_entry_time"
  end
end