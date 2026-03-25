class CreateLogReports < ActiveRecord::Migration[8.0]
  def change
    create_table :log_reports do |t|
      t.date :report_date, null: false
      t.integer :shift, null: false, default: 0

      t.references :department, null: false, foreign_key: true
      t.references :unit, null: false, foreign_key: true

      t.references :submitted_by, foreign_key: { to_table: :users }
      t.references :entered_by, null: false, foreign_key: { to_table: :users }

      t.text :summary
      t.text :general_remarks
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :log_reports, :report_date
    add_index :log_reports, :shift
    add_index :log_reports, :status
  end
end