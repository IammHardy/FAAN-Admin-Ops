class HardenNotifications < ActiveRecord::Migration[8.0]
  def change
    change_column_default :notifications, :read, from: nil, to: false
    change_column_null :notifications, :read, false, false

    change_column_null :notifications, :title, false
    change_column_null :notifications, :message, false

    add_index :notifications, :read
    add_index :notifications, [:user_id, :read]
  end
end