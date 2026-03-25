class CreateUnits < ActiveRecord::Migration[7.0]
  def change
    create_table :units do |t|
      t.references :department, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :units, [:department_id, :name], unique: true
    add_index :units, :active
  end
end