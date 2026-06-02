class AddCanBeOnDutyToOperationStaffs < ActiveRecord::Migration[8.0]
  def change
    add_column :operation_staffs,
               :can_be_on_duty,
               :boolean,
               default: false,
               null: false
  end
end