class CreateDutyRosters < ActiveRecord::Migration[8.0]
  def change
    create_table :duty_rosters do |t|
      t.references :operation_staff, null: false, foreign_key: true
      t.date :duty_date
      t.string :duty_area
      t.string :shift_name
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
