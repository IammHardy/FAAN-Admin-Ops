class AddSubmittedAtToLogReports < ActiveRecord::Migration[8.0]
  def change
    add_column :log_reports, :submitted_at, :datetime
  end
end
