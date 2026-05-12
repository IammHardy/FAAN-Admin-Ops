class AddUniqueIndexToLogReports < ActiveRecord::Migration[8.0]
  def change
    add_index :log_reports,
              [:report_date, :unit_id, :shift],
              unique: true,
              name: "index_log_reports_on_date_unit_shift_unique"
  end
end