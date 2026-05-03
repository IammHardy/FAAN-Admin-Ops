class CreateMinutes < ActiveRecord::Migration[8.0]
  def change
    create_table :minutes do |t|
      t.string :title
      t.text :transcript
      t.text :summary
      t.text :action_items
      t.integer :status, default: 0, null: false
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end