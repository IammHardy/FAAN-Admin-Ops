class AddMeetingDetailsToMinutes < ActiveRecord::Migration[8.0]
  def change
    add_column :minutes, :meeting_date, :date
    add_column :minutes, :venue, :string
  end
end
