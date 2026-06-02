class CreateRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :records do |t|
      t.string :title
      t.string :category
      t.date :document_date
      t.date :filed_date
      t.string :signed_by
      t.string :recipient_or_source
      t.string :reference_number
      t.string :physical_location
      t.text :notes
      t.references :filed_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
