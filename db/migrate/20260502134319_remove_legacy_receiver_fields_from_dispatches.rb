class RemoveLegacyReceiverFieldsFromDispatches < ActiveRecord::Migration[8.0]
  def change
    remove_reference :dispatches, :receiving_unit, foreign_key: { to_table: :units }
    remove_column :dispatches, :receiver_name, :string
    remove_column :dispatches, :receiver_designation, :string
    remove_column :dispatches, :received_by_id, :integer
    remove_column :dispatches, :acknowledged_by_id, :integer
    remove_column :dispatches, :received_at, :datetime
    remove_column :dispatches, :acknowledged_at, :datetime
    remove_column :dispatches, :acknowledgement_note, :text
  end
end