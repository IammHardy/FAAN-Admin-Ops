class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :full_name, :string
    add_column :users, :role, :integer, null: false, default: 1
    add_column :users, :phone_number, :string
    add_reference :users, :department, foreign_key: true
    add_reference :users, :unit, foreign_key: true
    add_column :users, :active, :boolean, null: false, default: true

    add_index :users, :role
    add_index :users, :active
  end
end