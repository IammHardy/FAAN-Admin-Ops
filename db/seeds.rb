
puts "Seeding FAAN Admin Operations System..."

demo_environment = Rails.env.development? || Rails.env.test?

# Password used for seeded accounts. It is read from SEED_PASSWORD so that no
# real credential ever lives in source control. In development/test we fall back
# to a well-known value for convenience; outside those environments a password
# MUST be provided or user accounts are skipped (so a fresh production deploy can
# never create a login with a publicly known password).
seed_password = ENV["SEED_PASSWORD"].presence
seed_password ||= "password123" if demo_environment

if demo_environment
  puts "Clearing existing development/test seed data..."

  MinuteAudioPart.destroy_all
  Minute.destroy_all
  Notification.destroy_all
  AuditLog.destroy_all
  Incident.destroy_all
  LogEntry.destroy_all
  LogReport.destroy_all
  DispatchRecipient.destroy_all
  Dispatch.destroy_all

  Record.destroy_all
  MonthlyReport.destroy_all

  DutySession.destroy_all
  DutyRoster.destroy_all
  OperationStaff.destroy_all

  User.destroy_all
  Unit.destroy_all
  Department.destroy_all
else
  puts "Production environment detected. Skipping destructive seed cleanup."
end

# Departments
operations = Department.find_or_create_by!(name: "Operations") do |department|
  department.description = "Airport operations department"
  department.active = true
end

engineering = Department.find_or_create_by!(name: "Engineering") do |department|
  department.description = "Engineering and maintenance department"
  department.active = true
end

security = Department.find_or_create_by!(name: "Security") do |department|
  department.description = "Airport security department"
  department.active = true
end

fire_service = Department.find_or_create_by!(name: "Fire Service") do |department|
  department.description = "Airport fire and rescue service"
  department.active = true
end

commercial = Department.find_or_create_by!(name: "Commercial") do |department|
  department.description = "Commercial and concessions department"
  department.active = true
end

puts "Departments created."

# Units
airport_admin = Unit.find_or_create_by!(department: operations, name: "Airport Admin") do |unit|
  unit.description = "Airport administration unit"
  unit.active = true
end

rgm_office = Unit.find_or_create_by!(department: operations, name: "RGM Office") do |unit|
  unit.description = "Regional General Manager office"
  unit.active = true
end

airfield = Unit.find_or_create_by!(department: operations, name: "Airfield") do |unit|
  unit.description = "Airfield operations unit"
  unit.active = true
end

apron_control = Unit.find_or_create_by!(department: operations, name: "Apron Control") do |unit|
  unit.description = "Apron control unit"
  unit.active = true
end

terminal_operations = Unit.find_or_create_by!(department: operations, name: "Terminal Operations") do |unit|
  unit.description = "Terminal operations unit"
  unit.active = true
end

house_management = Unit.find_or_create_by!(department: operations, name: "House Management DTZ B and D / ITZ") do |unit|
  unit.description = "House management unit for DTZ B and D / ITZ"
  unit.active = true
end

announcement = Unit.find_or_create_by!(department: operations, name: "Announcement DTZ / ITZ") do |unit|
  unit.description = "Announcement unit for DTZ / ITZ"
  unit.active = true
end

information = Unit.find_or_create_by!(department: operations, name: "Information DTZ / ITZ") do |unit|
  unit.description = "Information unit for DTZ / ITZ"
  unit.active = true
end

statistics = Unit.find_or_create_by!(department: operations, name: "Statistics") do |unit|
  unit.description = "Statistics unit"
  unit.active = true
end

puts "Units created."

# Primary administrator account (created in every environment).
# The password is only set when the account is first created, so re-running the
# seeds on a later deploy never overwrites a password the admin has since changed.
admin_email = ENV["SEED_ADMIN_EMAIL"].presence || "yusufabdulhadi567@gmail.com"
real_admin = User.find_or_initialize_by(email: admin_email)

if real_admin.new_record? && seed_password.blank?
  puts "WARNING: SEED_PASSWORD is not set; skipping creation of the admin account."
  puts "         Set SEED_PASSWORD and re-run `rails db:seed` to create #{admin_email}."
else
  real_admin.assign_attributes(
    full_name: "Yusuf Abdulhadi Adavize",
    role: :super_admin,
    phone_number: "08000000000",
    department: operations,
    unit: airport_admin,
    requires_duty_session: false,
    active: true
  )

  if real_admin.new_record?
    real_admin.password = seed_password
    real_admin.password_confirmation = seed_password
  end

  real_admin.save!
  puts "Admin account ensured (#{admin_email})."
end

# Real operational staff reference data (safe to seed in all environments).
admin_staff = [
  ["Mr Nuhu P. Nanloh", "HOD Operations", "Permanent Staff", true, false],
  ["Mr Anietie John Udoh", "HOU Operations", "Permanent Staff", true, false],
  ["Mr Abdulsalam", "Compliance Officer", "Permanent Staff", true, false],
  ["Mr Luqman", "Compliance Officer", "Permanent Staff", true, false],

  ["Miss Bilkisu Ashara", "Secretary", "Permanent Staff", false, true],
  ["Mrs Rabia Maikudi", "Secretary", "Permanent Staff", false, true],
  ["Mrs Rukaya Zakari", "Secretary", "Permanent Staff", false, true],
  ["Mrs Sudai Gambo", "Secretary", "Permanent Staff", false, true],
  ["Madam Precious", "Admin Officer", "Permanent Staff", false, true],
  ["Mrs Hadiza", "Admin Officer", "Permanent Staff", false, true],
  ["Yusuf Abdulhadi Adavize", "NYSC", "NYSC", false, true],
  ["Chinecherem Evelyn", "NYSC", "NYSC", false, true]
]

admin_staff.each do |full_name, designation, status, always_present, can_be_on_duty|
  staff = OperationStaff.find_or_initialize_by(full_name: full_name)

  staff.assign_attributes(
    designation: designation,
    unit: "Airport Admin",
    employment_status: status,
    physical_folder_location: "Airport Admin Staff Folder",
    always_present: always_present,
    can_be_on_duty: can_be_on_duty,
    duty_area: "Admin Office"
  )

  staff.save!
end

puts "Admin staff created."

rgm_staff = [
  ["RGM Secretary Female", "Secretary", "Permanent Staff"],
  ["RGM Secretary Male", "Secretary", "Permanent Staff"]
]

rgm_staff.each do |full_name, designation, status|
  staff = OperationStaff.find_or_initialize_by(full_name: full_name)

  staff.assign_attributes(
    designation: designation,
    unit: "RGM Office",
    employment_status: status,
    physical_folder_location: "RGM Office Staff Folder",
    always_present: false,
    can_be_on_duty: false,
    duty_area: nil
  )

  staff.save!
end

puts "RGM staff created."

# ---------------------------------------------------------------------------
# Demo accounts and sample data.
# These use placeholder ".local" logins and a shared demo password, so they are
# ONLY created in development/test. They must never exist on a public deploy.
# ---------------------------------------------------------------------------
unless demo_environment
  puts "Skipping demo accounts and sample data outside development/test."
  puts "Seed complete."
  return
end

build_user = lambda do |email, attrs|
  user = User.find_or_initialize_by(email: email)
  user.assign_attributes(attrs.merge(password: seed_password, password_confirmation: seed_password))
  user.save!
  user
end

super_admin = build_user.call("admin@faan.local",
  full_name: "System Administrator",
  role: :super_admin,
  phone_number: "08010000001",
  department: operations,
  unit: airport_admin,
  requires_duty_session: false,
  active: true)

admin_officer = build_user.call("adminofficer@faan.local",
  full_name: "Admin Officer",
  role: :admin_officer,
  phone_number: "08010000002",
  department: operations,
  unit: airport_admin,
  requires_duty_session: true,
  active: true)

dispatch_officer = build_user.call("dispatch@faan.local",
  full_name: "Dispatch Officer",
  role: :dispatch_officer,
  phone_number: "08010000003",
  department: operations,
  unit: airport_admin,
  requires_duty_session: true,
  active: true)

unit_officer = build_user.call("unitofficer@faan.local",
  full_name: "Unit Officer",
  role: :unit_officer,
  phone_number: "08010000004",
  department: operations,
  unit: terminal_operations,
  requires_duty_session: true,
  active: true)

reviewer = build_user.call("reviewer@faan.local",
  full_name: "HOD Reviewer",
  role: :reviewer,
  phone_number: "08010000005",
  department: operations,
  unit: terminal_operations,
  requires_duty_session: false,
  active: true)

rgm_user = build_user.call("rgmoffice@faan.local",
  full_name: "RGM Office",
  role: :unit_officer,
  phone_number: "08010000006",
  department: operations,
  unit: rgm_office,
  requires_duty_session: true,
  active: true)

puts "Demo users created."

# Sample Dispatches
dispatch_1 = Dispatch.find_or_initialize_by(reference_number: "DPT-#{Date.current.year}-0001")
dispatch_1.assign_attributes(
  subject: "Submission of Daily Operations Summary",
  memo_date: Date.current,
  sender_department: operations,
  sender_unit: airport_admin,
  receiving_department: operations,
  created_by: admin_officer,
  delivery_note: "Kindly receive and review.",
  remarks: "Urgent memo for action.",
  status: :draft
)
dispatch_1.save!

dispatch_1.dispatch_recipients.find_or_create_by!(receiving_unit: terminal_operations) do |recipient|
  recipient.status = :dispatched
end

dispatch_2 = Dispatch.find_or_initialize_by(reference_number: "DPT-#{Date.current.year}-0002")
dispatch_2.assign_attributes(
  subject: "Incident Notification Report",
  memo_date: Date.current - 1.day,
  sender_department: operations,
  sender_unit: terminal_operations,
  receiving_department: operations,
  created_by: admin_officer,
  dispatched_by: dispatch_officer,
  dispatched_at: Time.current - 12.hours,
  delivery_note: "Please acknowledge receipt.",
  remarks: "Related to terminal crowd control issue.",
  status: :dispatched
)
dispatch_2.save!

dispatch_2.dispatch_recipients.find_or_create_by!(receiving_unit: rgm_office) do |recipient|
  recipient.status = :dispatched
end

dispatch_3 = Dispatch.find_or_initialize_by(reference_number: "DPT-#{Date.current.year}-0003")
dispatch_3.assign_attributes(
  subject: "Maintenance Request for Office Printer",
  memo_date: Date.current - 2.days,
  sender_department: operations,
  sender_unit: airport_admin,
  receiving_department: operations,
  created_by: admin_officer,
  dispatched_by: dispatch_officer,
  dispatched_at: Time.current - 2.days,
  delivery_note: "For urgent repair.",
  remarks: "Printer in admin office not functioning.",
  status: :dispatched
)
dispatch_3.save!

dispatch_3.dispatch_recipients.find_or_create_by!(receiving_unit: apron_control) do |recipient|
  recipient.status = :received
  recipient.receiver_name = "Mr. Ibrahim" if recipient.respond_to?(:receiver_name=)
  recipient.receiver_designation = "Apron Control Officer" if recipient.respond_to?(:receiver_designation=)
  recipient.received_by = unit_officer if recipient.respond_to?(:received_by=)
  recipient.received_at = Time.current - 1.day if recipient.respond_to?(:received_at=)
end

puts "Dispatches created."

# Sample Log Reports
log_report_1 = LogReport.find_or_initialize_by(
  report_date: Date.current,
  department: operations,
  unit: terminal_operations,
  shift: :morning
)

log_report_1.assign_attributes(
  shift: :morning,
  entered_by: admin_officer,
  submitted_by: unit_officer,
  summary: "Morning terminal activities were generally smooth with a minor queue management issue.",
  general_remarks: "Passenger flow improved after intervention.",
  status: :submitted
)
log_report_1.save!

if log_report_1.log_entries.empty?
  entry_1 = log_report_1.log_entries.create!(
    entry_time: "08:15",
    description: "Terminal opened for passenger processing.",
    incident_flag: false,
    action_taken: "Routine operations commenced.",
    follow_up_needed: false
  )

  entry_2 = log_report_1.log_entries.create!(
    entry_time: "09:40",
    description: "Crowd congestion noticed at boarding gate B.",
    incident_flag: true,
    action_taken: "Additional staff deployed to manage queue.",
    follow_up_needed: true
  )

  entry_3 = log_report_1.log_entries.create!(
    entry_time: "10:25",
    description: "Public address system briefly malfunctioned.",
    incident_flag: true,
    action_taken: "Engineering team informed.",
    follow_up_needed: true
  )

  Incident.find_or_create_by!(incident_number: "INC-#{Date.current.year}-0001") do |incident|
    incident.log_report = log_report_1
    incident.log_entry = entry_2
    incident.title = "Passenger Congestion at Boarding Gate B"
    incident.description = "Heavy passenger congestion developed at boarding gate B during the morning shift."
    incident.incident_type = :operational
    incident.severity = :medium
    incident.action_taken = "Queue managed by deploying additional staff."
    incident.escalation_required = false
    incident.status = :under_review
    incident.reviewer_remark = "Monitor traffic during peak hours."
    incident.created_by = admin_officer
    incident.reviewed_by = reviewer
  end

  Incident.find_or_create_by!(incident_number: "INC-#{Date.current.year}-0002") do |incident|
    incident.log_report = log_report_1
    incident.log_entry = entry_3
    incident.title = "PA System Malfunction"
    incident.description = "Public address system malfunctioned briefly at the terminal."
    incident.incident_type = :engineering
    incident.severity = :high
    incident.action_taken = "Engineering team notified immediately."
    incident.escalation_required = true
    incident.escalated_to = "Head of Engineering"
    incident.escalated_at = Time.current - 3.hours
    incident.status = :escalated
    incident.reviewer_remark = "Urgent attention required to avoid recurrence."
    incident.created_by = admin_officer
    incident.reviewed_by = reviewer
  end
end

puts "Log reports, log entries, and incidents created."

# Optional Audit Logs
AuditLog.find_or_create_by!(
  user: admin_officer,
  action: "create",
  auditable: dispatch_1
) do |log|
  log.description = "Created dispatch #{dispatch_1.reference_number}"
end

AuditLog.find_or_create_by!(
  user: admin_officer,
  action: "create",
  auditable: log_report_1
) do |log|
  log.description = "Created log report for #{log_report_1.unit.name} on #{log_report_1.report_date}"
end

puts "Audit logs created."

puts "Seed complete."
puts
puts "Demo login accounts (development/test only):"
puts "Super Admin: admin@faan.local"
puts "Admin Officer: adminofficer@faan.local"
puts "Dispatch Officer: dispatch@faan.local"
puts "Unit Officer: unitofficer@faan.local"
puts "Reviewer: reviewer@faan.local"
puts "Password: value of SEED_PASSWORD (defaults to \"password123\" in dev/test)"
