
puts "Seeding FAAN Admin Operations System..."

if Rails.env.development? || Rails.env.test?
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

terminal_operations = Unit.find_or_create_by!(department: operations, name: "Terminal Operations") do |unit|
  unit.description = "Terminal operations unit"
  unit.active = true
end

apron_management = Unit.find_or_create_by!(department: operations, name: "Apron Management") do |unit|
  unit.description = "Apron management unit"
  unit.active = true
end

electrical_unit = Unit.find_or_create_by!(department: engineering, name: "Electrical Unit") do |unit|
  unit.description = "Electrical maintenance unit"
  unit.active = true
end

mechanical_unit = Unit.find_or_create_by!(department: engineering, name: "Mechanical Unit") do |unit|
  unit.description = "Mechanical maintenance unit"
  unit.active = true
end

aviation_security = Unit.find_or_create_by!(department: security, name: "Aviation Security") do |unit|
  unit.description = "Security operations unit"
  unit.active = true
end

rescue_unit = Unit.find_or_create_by!(department: fire_service, name: "Rescue Unit") do |unit|
  unit.description = "Emergency rescue unit"
  unit.active = true
end

concessions_unit = Unit.find_or_create_by!(department: commercial, name: "Concessions Unit") do |unit|
  unit.description = "Commercial concessions unit"
  unit.active = true
end

puts "Units created."

# Users
super_admin = User.find_or_initialize_by(email: "admin@faan.local")
super_admin.assign_attributes(
  full_name: "System Administrator",
  password: "password123",
  password_confirmation: "password123",
  role: :super_admin,
  phone_number: "08010000001",
  department: operations,
  unit: airport_admin,
  active: true
)
super_admin.save!

real_admin = User.find_or_initialize_by(email: "yusufabdulhadi567@gmail.com")
real_admin.assign_attributes(
  full_name: "Yusuf Abdulhadi Adavize",
  password: "password123",
  password_confirmation: "password123",
  role: :super_admin,
  phone_number: "08000000000",
  department: operations,
  unit: airport_admin,
  active: true
)
real_admin.save!

admin_officer = User.find_or_initialize_by(email: "adminofficer@faan.local")
admin_officer.assign_attributes(
  full_name: "Admin Officer",
  password: "password123",
  password_confirmation: "password123",
  role: :admin_officer,
  phone_number: "08010000002",
  department: operations,
  unit: airport_admin,
  active: true
)
admin_officer.save!

dispatch_officer = User.find_or_initialize_by(email: "dispatch@faan.local")
dispatch_officer.assign_attributes(
  full_name: "Dispatch Officer",
  password: "password123",
  password_confirmation: "password123",
  role: :dispatch_officer,
  phone_number: "08010000003",
  department: operations,
  unit: airport_admin,
  active: true
)
dispatch_officer.save!

unit_officer = User.find_or_initialize_by(email: "unitofficer@faan.local")
unit_officer.assign_attributes(
  full_name: "Unit Officer",
  password: "password123",
  password_confirmation: "password123",
  role: :unit_officer,
  phone_number: "08010000004",
  department: engineering,
  unit: electrical_unit,
  active: true
)
unit_officer.save!

reviewer = User.find_or_initialize_by(email: "reviewer@faan.local")
reviewer.assign_attributes(
  full_name: "HOD Reviewer",
  password: "password123",
  password_confirmation: "password123",
  role: :reviewer,
  phone_number: "08010000005",
  department: operations,
  unit: terminal_operations,
  active: true
)
reviewer.save!

puts "Users created."

# Sample Dispatches
dispatch_1 = Dispatch.find_or_initialize_by(reference_number: "DPT-#{Date.current.year}-0001")
dispatch_1.assign_attributes(
  subject: "Submission of Daily Operations Summary",
  memo_date: Date.current,
  sender_department: operations,
  sender_unit: airport_admin,
  receiving_department: engineering,
  created_by: admin_officer,
  delivery_note: "Kindly receive and review.",
  remarks: "Urgent memo for action.",
  status: :draft
)
dispatch_1.save!

dispatch_1.dispatch_recipients.find_or_create_by!(receiving_unit: electrical_unit) do |recipient|
  recipient.status = :dispatched
end

dispatch_2 = Dispatch.find_or_initialize_by(reference_number: "DPT-#{Date.current.year}-0002")
dispatch_2.assign_attributes(
  subject: "Incident Notification Report",
  memo_date: Date.current - 1.day,
  sender_department: operations,
  sender_unit: terminal_operations,
  receiving_department: security,
  created_by: admin_officer,
  dispatched_by: dispatch_officer,
  dispatched_at: Time.current - 12.hours,
  delivery_note: "Please acknowledge receipt.",
  remarks: "Related to terminal crowd control issue.",
  status: :dispatched
)
dispatch_2.save!

dispatch_2.dispatch_recipients.find_or_create_by!(receiving_unit: aviation_security) do |recipient|
  recipient.status = :dispatched
end

dispatch_3 = Dispatch.find_or_initialize_by(reference_number: "DPT-#{Date.current.year}-0003")
dispatch_3.assign_attributes(
  subject: "Maintenance Request for Office Printer",
  memo_date: Date.current - 2.days,
  sender_department: operations,
  sender_unit: airport_admin,
  receiving_department: engineering,
  created_by: admin_officer,
  dispatched_by: dispatch_officer,
  dispatched_at: Time.current - 2.days,
  delivery_note: "For urgent repair.",
  remarks: "Printer in admin office not functioning.",
  status: :dispatched
)
dispatch_3.save!

dispatch_3.dispatch_recipients.find_or_create_by!(receiving_unit: mechanical_unit) do |recipient|
  recipient.status = :received
  recipient.receiver_name = "Engr. Musa" if recipient.respond_to?(:receiver_name=)
  recipient.receiver_designation = "Maintenance Supervisor" if recipient.respond_to?(:receiver_designation=)
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
puts "Login accounts:"
puts "Real Admin: yusufabdulhadi567@gmail.com / password123"
puts "Super Admin: admin@faan.local / password123"
puts "Admin Officer: adminofficer@faan.local / password123"
puts "Dispatch Officer: dispatch@faan.local / password123"
puts "Unit Officer: unitofficer@faan.local / password123"
puts "Reviewer: reviewer@faan.local / password123"