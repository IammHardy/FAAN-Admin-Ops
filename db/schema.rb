# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_05_03_074109) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "action", null: false
    t.string "auditable_type", null: false
    t.bigint "auditable_id", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_departments_on_active"
    t.index ["name"], name: "index_departments_on_name", unique: true
  end

  create_table "dispatch_recipients", force: :cascade do |t|
    t.bigint "dispatch_id", null: false
    t.bigint "receiving_unit_id", null: false
    t.integer "status", default: 0, null: false
    t.string "receiver_name"
    t.string "receiver_designation"
    t.bigint "received_by_id"
    t.bigint "acknowledged_by_id"
    t.datetime "received_at"
    t.datetime "acknowledged_at"
    t.text "acknowledgement_note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["acknowledged_by_id"], name: "index_dispatch_recipients_on_acknowledged_by_id"
    t.index ["dispatch_id", "receiving_unit_id"], name: "index_dispatch_recipients_on_dispatch_id_and_receiving_unit_id", unique: true
    t.index ["dispatch_id"], name: "index_dispatch_recipients_on_dispatch_id"
    t.index ["received_by_id"], name: "index_dispatch_recipients_on_received_by_id"
    t.index ["receiving_unit_id"], name: "index_dispatch_recipients_on_receiving_unit_id"
  end

  create_table "dispatches", force: :cascade do |t|
    t.string "reference_number", null: false
    t.string "subject", null: false
    t.date "memo_date", null: false
    t.bigint "sender_department_id", null: false
    t.bigint "sender_unit_id"
    t.bigint "receiving_department_id", null: false
    t.bigint "created_by_id", null: false
    t.bigint "dispatched_by_id"
    t.datetime "dispatched_at"
    t.integer "status", default: 0, null: false
    t.text "delivery_note"
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_dispatches_on_created_by_id"
    t.index ["dispatched_by_id"], name: "index_dispatches_on_dispatched_by_id"
    t.index ["memo_date"], name: "index_dispatches_on_memo_date"
    t.index ["receiving_department_id"], name: "index_dispatches_on_receiving_department_id"
    t.index ["reference_number"], name: "index_dispatches_on_reference_number", unique: true
    t.index ["sender_department_id"], name: "index_dispatches_on_sender_department_id"
    t.index ["sender_unit_id"], name: "index_dispatches_on_sender_unit_id"
    t.index ["status"], name: "index_dispatches_on_status"
  end

  create_table "incidents", force: :cascade do |t|
    t.string "incident_number", null: false
    t.bigint "log_report_id", null: false
    t.bigint "log_entry_id", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.integer "incident_type", default: 0, null: false
    t.integer "severity", default: 0, null: false
    t.text "action_taken"
    t.boolean "escalation_required", default: false, null: false
    t.string "escalated_to"
    t.datetime "escalated_at"
    t.integer "status", default: 0, null: false
    t.text "reviewer_remark"
    t.bigint "created_by_id", null: false
    t.bigint "reviewed_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_incidents_on_created_by_id"
    t.index ["escalation_required"], name: "index_incidents_on_escalation_required"
    t.index ["incident_number"], name: "index_incidents_on_incident_number", unique: true
    t.index ["incident_type"], name: "index_incidents_on_incident_type"
    t.index ["log_entry_id"], name: "index_incidents_on_log_entry_id"
    t.index ["log_report_id"], name: "index_incidents_on_log_report_id"
    t.index ["reviewed_by_id"], name: "index_incidents_on_reviewed_by_id"
    t.index ["severity"], name: "index_incidents_on_severity"
    t.index ["status"], name: "index_incidents_on_status"
  end

  create_table "log_entries", force: :cascade do |t|
    t.bigint "log_report_id", null: false
    t.time "entry_time"
    t.text "description", null: false
    t.boolean "incident_flag", default: false, null: false
    t.text "action_taken"
    t.boolean "follow_up_needed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["follow_up_needed"], name: "index_log_entries_on_follow_up_needed"
    t.index ["incident_flag"], name: "index_log_entries_on_incident_flag"
    t.index ["log_report_id"], name: "index_log_entries_on_log_report_id"
  end

  create_table "log_reports", force: :cascade do |t|
    t.date "report_date", null: false
    t.integer "shift", default: 0, null: false
    t.bigint "department_id", null: false
    t.bigint "unit_id", null: false
    t.bigint "submitted_by_id"
    t.bigint "entered_by_id", null: false
    t.text "summary"
    t.text "general_remarks"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "submitted_at"
    t.index ["department_id"], name: "index_log_reports_on_department_id"
    t.index ["entered_by_id"], name: "index_log_reports_on_entered_by_id"
    t.index ["report_date"], name: "index_log_reports_on_report_date"
    t.index ["shift"], name: "index_log_reports_on_shift"
    t.index ["status"], name: "index_log_reports_on_status"
    t.index ["submitted_by_id"], name: "index_log_reports_on_submitted_by_id"
    t.index ["unit_id"], name: "index_log_reports_on_unit_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "message"
    t.boolean "read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "units", force: :cascade do |t|
    t.bigint "department_id", null: false
    t.string "name", null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_units_on_active"
    t.index ["department_id", "name"], name: "index_units_on_department_id_and_name", unique: true
    t.index ["department_id"], name: "index_units_on_department_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "full_name"
    t.integer "role", default: 1, null: false
    t.string "phone_number"
    t.bigint "department_id"
    t.bigint "unit_id"
    t.boolean "active", default: true, null: false
    t.index ["active"], name: "index_users_on_active"
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["unit_id"], name: "index_users_on_unit_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "dispatch_recipients", "dispatches"
  add_foreign_key "dispatch_recipients", "units", column: "receiving_unit_id"
  add_foreign_key "dispatch_recipients", "users", column: "acknowledged_by_id"
  add_foreign_key "dispatch_recipients", "users", column: "received_by_id"
  add_foreign_key "dispatches", "departments", column: "receiving_department_id"
  add_foreign_key "dispatches", "departments", column: "sender_department_id"
  add_foreign_key "dispatches", "units", column: "sender_unit_id"
  add_foreign_key "dispatches", "users", column: "created_by_id"
  add_foreign_key "dispatches", "users", column: "dispatched_by_id"
  add_foreign_key "incidents", "log_entries"
  add_foreign_key "incidents", "log_reports"
  add_foreign_key "incidents", "users", column: "created_by_id"
  add_foreign_key "incidents", "users", column: "reviewed_by_id"
  add_foreign_key "log_entries", "log_reports"
  add_foreign_key "log_reports", "departments"
  add_foreign_key "log_reports", "units"
  add_foreign_key "log_reports", "users", column: "entered_by_id"
  add_foreign_key "log_reports", "users", column: "submitted_by_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "units", "departments"
  add_foreign_key "users", "departments"
  add_foreign_key "users", "units"
end
