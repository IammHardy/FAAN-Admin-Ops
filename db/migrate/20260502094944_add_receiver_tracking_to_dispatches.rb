class AddReceiverTrackingToDispatches < ActiveRecord::Migration[8.0]
  def change
    add_column :dispatches, :received_by_id, :integer
    add_column :dispatches, :acknowledged_by_id, :integer
    add_column :dispatches, :acknowledged_at, :datetime
    add_column :dispatches, :acknowledgement_note, :text

    add_index :dispatches, :received_by_id
    add_index :dispatches, :acknowledged_by_id
  end
end