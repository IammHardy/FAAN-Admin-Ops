class CreateDispatchRecipients < ActiveRecord::Migration[8.0]
  def change
    create_table :dispatch_recipients do |t|
      t.references :dispatch, null: false, foreign_key: true
      t.references :receiving_unit, null: false, foreign_key: { to_table: :units }

      t.integer :status, null: false, default: 0

      t.string :receiver_name
      t.string :receiver_designation

      t.references :received_by, foreign_key: { to_table: :users }
      t.references :acknowledged_by, foreign_key: { to_table: :users }

      t.datetime :received_at
      t.datetime :acknowledged_at
      t.text :acknowledgement_note

      t.timestamps
    end

    add_index :dispatch_recipients, [:dispatch_id, :receiving_unit_id], unique: true
  end
end