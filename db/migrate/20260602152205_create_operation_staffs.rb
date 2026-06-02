class CreateOperationStaffs < ActiveRecord::Migration[8.0]
  def change
    create_table :operation_staffs do |t|
      t.string :full_name
      t.string :staff_number
      t.string :designation
      t.string :unit
      t.string :phone_number
      t.string :email
      t.string :employment_status
      t.string :physical_folder_location
      t.text :notes

      t.timestamps
    end
  end
end
