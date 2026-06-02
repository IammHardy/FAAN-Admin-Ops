class SetDutySessionRequirementForSharedUsers < ActiveRecord::Migration[8.0]
  def up
    change_column_default :users, :requires_duty_session, from: nil, to: false

    User.reset_column_information

    User.where(email: [
      "adminofficer@faan.local",
      "dispatch@faan.local",
      "unitofficer@faan.local"
    ]).update_all(requires_duty_session: true)

    User.where(email: [
      "admin@faan.local",
      "yusufabdulhadi567@gmail.com",
      "reviewer@faan.local"
    ]).update_all(requires_duty_session: false)
  end

  def down
    change_column_default :users, :requires_duty_session, from: false, to: nil
  end
end