class AddAlwaysPresentToOperationStaffs < ActiveRecord::Migration[8.0]
  def change
    add_column :operation_staffs,
               :always_present,
               :boolean,
               default: false,
               null: false
  end
end