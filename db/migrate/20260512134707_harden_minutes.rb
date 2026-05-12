class HardenMinutes < ActiveRecord::Migration[8.0]
  def change
    change_column_null :minutes, :title, false

    add_index :minutes, :status
    add_index :minutes, :created_at
    add_index :minutes, [:created_by_id, :status]
  end
end