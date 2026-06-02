class AddDutyAreaToOperationStaffs < ActiveRecord::Migration[8.0]
  def change
    add_column :operation_staffs, :duty_area, :string
  end
end
