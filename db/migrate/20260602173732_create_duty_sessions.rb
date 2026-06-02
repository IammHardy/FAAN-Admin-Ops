class CreateDutySessions < ActiveRecord::Migration[8.0]
  def change
    create_table :duty_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :operation_staff, null: false, foreign_key: true
      t.references :duty_roster, null: false, foreign_key: true
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
