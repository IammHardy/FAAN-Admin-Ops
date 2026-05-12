class MakeUsersFullNameRequired < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :full_name, false
  end
end