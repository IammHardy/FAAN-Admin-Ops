class CreateMinuteAudioParts < ActiveRecord::Migration[8.0]
  def change
    create_table :minute_audio_parts do |t|
      t.references :minute, null: false, foreign_key: true
      t.integer :position
      t.text :transcript
      t.integer :status

      t.timestamps
    end
  end
end
