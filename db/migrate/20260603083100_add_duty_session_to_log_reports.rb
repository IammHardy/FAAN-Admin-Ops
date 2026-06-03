class AddDutySessionToLogReports < ActiveRecord::Migration[8.0]
  def change
    add_reference :log_reports, :duty_session, null: true, foreign_key: true
  end
end
