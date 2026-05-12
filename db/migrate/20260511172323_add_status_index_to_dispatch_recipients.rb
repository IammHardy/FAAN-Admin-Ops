class AddStatusIndexToDispatchRecipients < ActiveRecord::Migration[8.0]
  def change
    add_index :dispatch_recipients, :status
  end
end