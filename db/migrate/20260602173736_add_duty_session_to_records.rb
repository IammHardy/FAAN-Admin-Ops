class AddDutySessionToRecords < ActiveRecord::Migration[8.0]
  def change
    add_reference :records, :duty_session, null: true, foreign_key: true
  end
end
