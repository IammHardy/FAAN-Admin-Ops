class CreateDispatches < ActiveRecord::Migration[8.0]
  def change
    create_table :dispatches do |t|
      t.string :reference_number, null: false
      t.string :subject, null: false
      t.date :memo_date, null: false

      t.references :sender_department, null: false, foreign_key: { to_table: :departments }
      t.references :sender_unit, foreign_key: { to_table: :units }
      t.references :receiving_department, null: false, foreign_key: { to_table: :departments }
      t.references :receiving_unit, foreign_key: { to_table: :units }

      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :dispatched_by, foreign_key: { to_table: :users }

      t.string :receiver_name
      t.string :receiver_designation
      t.datetime :dispatched_at
      t.datetime :received_at

      t.integer :status, null: false, default: 0
      t.text :delivery_note
      t.text :remarks

      t.timestamps
    end

    add_index :dispatches, :reference_number, unique: true
    add_index :dispatches, :memo_date
    add_index :dispatches, :status
  end
end