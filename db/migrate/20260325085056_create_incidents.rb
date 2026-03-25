class CreateIncidents < ActiveRecord::Migration[8.0]
  def change
    create_table :incidents do |t|
      t.string :incident_number, null: false

      t.references :log_report, null: false, foreign_key: true
      t.references :log_entry, null: false, foreign_key: true

      t.string :title, null: false
      t.text :description, null: false

      t.integer :incident_type, null: false, default: 0
      t.integer :severity, null: false, default: 0
      t.text :action_taken

      t.boolean :escalation_required, null: false, default: false
      t.string :escalated_to
      t.datetime :escalated_at

      t.integer :status, null: false, default: 0
      t.text :reviewer_remark

      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :reviewed_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :incidents, :incident_number, unique: true
    add_index :incidents, :incident_type
    add_index :incidents, :severity
    add_index :incidents, :status
    add_index :incidents, :escalation_required
  end
end