class AddNotificationPreferencesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :email_notifications_enabled, :boolean, default: true, null: false
    add_column :users, :sms_notifications_enabled, :boolean, default: false, null: false
  end
end