class CreateMonthlyReports < ActiveRecord::Migration[8.0]
  def change
    create_table :monthly_reports do |t|
      t.string :title
      t.date :report_month
      t.integer :status
      t.references :department, null: false, foreign_key: true
      t.references :unit, null: false, foreign_key: true
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }
t.references :reviewed_by, foreign_key: { to_table: :users }
      t.datetime :reviewed_at
      t.text :remarks

      t.timestamps
    end
  end
end
