class AddRequiresDutySessionToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :requires_duty_session, :boolean
  end
end
