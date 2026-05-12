class HardenMinuteAudioParts < ActiveRecord::Migration[8.0]
  def change
    change_column_default :minute_audio_parts, :status, from: nil, to: 0
    change_column_null :minute_audio_parts, :status, false, 0
    change_column_null :minute_audio_parts, :position, false

    add_index :minute_audio_parts, :status
    add_index :minute_audio_parts,
              [:minute_id, :position],
              unique: true,
              name: "index_minute_audio_parts_on_minute_and_position"
  end
end