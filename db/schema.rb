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

ActiveRecord::Schema[8.0].define(version: 2025_10_20_101506) do
  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "icon"
    t.string "color"
    t.boolean "member_can_create", default: false, null: false
    t.boolean "active", default: true, null: false
    t.integer "display_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "church_id", null: false
    t.integer "category_type", default: 0, null: false
    t.index ["church_id", "name"], name: "index_categories_on_church_id_and_name", unique: true
  end

  create_table "checklist_completions", force: :cascade do |t|
    t.integer "need_signup_id", null: false
    t.integer "checklist_item_id", null: false
    t.boolean "completed", default: false, null: false
    t.datetime "completed_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["checklist_item_id"], name: "index_checklist_completions_on_checklist_item_id"
    t.index ["need_signup_id"], name: "index_checklist_completions_on_need_signup_id"
  end

  create_table "checklist_items", force: :cascade do |t|
    t.integer "checklist_id", null: false
    t.text "description", null: false
    t.integer "display_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["checklist_id", "display_order"], name: "index_checklist_items_on_checklist_id_and_display_order"
    t.index ["checklist_id"], name: "index_checklist_items_on_checklist_id"
  end

  create_table "checklists", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "created_by_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "church_id", null: false
    t.integer "content_type", default: 0, null: false
    t.index ["church_id"], name: "index_checklists_on_church_id"
    t.index ["content_type"], name: "index_checklists_on_content_type"
    t.index ["created_by_id"], name: "index_checklists_on_created_by_id"
  end

  create_table "churches", force: :cascade do |t|
    t.string "name", null: false
    t.text "address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "phone"
    t.string "email"
    t.string "website"
    t.string "timezone", default: "America/New_York"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_churches_on_active"
    t.index ["name"], name: "index_churches_on_name"
  end

  create_table "need_signups", force: :cascade do |t|
    t.integer "need_id", null: false
    t.integer "user_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "signed_up_at", null: false
    t.datetime "cancelled_at"
    t.text "cancellation_reason"
    t.datetime "completed_at"
    t.date "specific_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["need_id", "user_id", "specific_date"], name: "index_need_signups_uniqueness", unique: true
    t.index ["need_id"], name: "index_need_signups_on_need_id"
    t.index ["status"], name: "index_need_signups_on_status"
    t.index ["user_id"], name: "index_need_signups_on_user_id"
  end

  create_table "needs", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.integer "category_id", null: false
    t.integer "creator_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "need_type", default: 0, null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.integer "time_slot"
    t.time "specific_time"
    t.string "location"
    t.integer "volunteer_capacity", default: 1, null: false
    t.boolean "allow_individual_day_signup", default: false, null: false
    t.boolean "is_recurring", default: false, null: false
    t.string "recurrence_pattern"
    t.date "recurrence_end_date"
    t.integer "parent_need_id"
    t.datetime "approved_at"
    t.integer "approved_by_id"
    t.datetime "completed_at"
    t.integer "completed_by_id"
    t.integer "checklist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "church_id", null: false
    t.integer "recurrence_start_day"
    t.integer "recurrence_end_day"
    t.integer "content_type", default: 0, null: false
    t.index ["approved_by_id"], name: "index_needs_on_approved_by_id"
    t.index ["category_id"], name: "index_needs_on_category_id"
    t.index ["checklist_id"], name: "index_needs_on_checklist_id"
    t.index ["church_id"], name: "index_needs_on_church_id"
    t.index ["completed_by_id"], name: "index_needs_on_completed_by_id"
    t.index ["content_type"], name: "index_needs_on_content_type"
    t.index ["creator_id"], name: "index_needs_on_creator_id"
    t.index ["need_type"], name: "index_needs_on_need_type"
    t.index ["parent_need_id"], name: "index_needs_on_parent_need_id"
    t.index ["start_date"], name: "index_needs_on_start_date"
    t.index ["status"], name: "index_needs_on_status"
  end

  create_table "notification_preferences", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "notification_type", null: false
    t.boolean "email_enabled", default: true, null: false
    t.boolean "sms_enabled", default: false, null: false
    t.boolean "in_app_enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "notification_type"], name: "index_notification_prefs_uniqueness", unique: true
    t.index ["user_id"], name: "index_notification_preferences_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "notification_type", null: false
    t.string "title", null: false
    t.text "message", null: false
    t.string "related_type"
    t.integer "related_id"
    t.boolean "read", default: false, null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["related_type", "related_id"], name: "index_notifications_on_related_type_and_related_id"
    t.index ["user_id", "read"], name: "index_notifications_on_user_id_and_read"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "room_bookings", force: :cascade do |t|
    t.integer "need_id", null: false
    t.integer "room_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "requested_by_id", null: false
    t.integer "approved_by_id"
    t.datetime "approved_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved_by_id"], name: "index_room_bookings_on_approved_by_id"
    t.index ["need_id", "room_id"], name: "index_room_bookings_on_need_id_and_room_id", unique: true
    t.index ["need_id"], name: "index_room_bookings_on_need_id"
    t.index ["requested_by_id"], name: "index_room_bookings_on_requested_by_id"
    t.index ["room_id"], name: "index_room_bookings_on_room_id"
    t.index ["status"], name: "index_room_bookings_on_status"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "capacity"
    t.integer "church_id", null: false
    t.boolean "active", default: true, null: false
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_rooms_on_active"
    t.index ["church_id", "name"], name: "index_rooms_on_church_id_and_name", unique: true
    t.index ["church_id"], name: "index_rooms_on_church_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "restore_token"
    t.index ["restore_token"], name: "index_sessions_on_restore_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer "church_id", null: false
    t.string "stripe_subscription_id"
    t.string "stripe_customer_id"
    t.integer "status", default: 0, null: false
    t.integer "amount_cents", default: 2500, null: false
    t.string "currency", default: "usd", null: false
    t.string "interval", default: "year", null: false
    t.datetime "current_period_start"
    t.datetime "current_period_end"
    t.boolean "cancel_at_period_end", default: false, null: false
    t.datetime "canceled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["church_id"], name: "index_subscriptions_on_church_id"
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["stripe_subscription_id"], name: "index_subscriptions_on_stripe_subscription_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "phone"
    t.text "bio"
    t.integer "role", default: 0, null: false
    t.boolean "email_verified", default: false, null: false
    t.boolean "active", default: true, null: false
    t.string "timezone", default: "America/New_York"
    t.integer "theme_preference", default: 0, null: false
    t.integer "church_id", null: false
    t.boolean "is_church_admin", default: false, null: false
    t.boolean "is_owner", default: false, null: false
    t.integer "email_bounce_status", default: 0, null: false
    t.datetime "email_bounced_at"
    t.datetime "email_complaint_at"
    t.boolean "email_suppressed", default: false, null: false
    t.datetime "last_email_sent_at"
    t.integer "bounce_count", default: 0, null: false
    t.index ["church_id", "is_church_admin"], name: "index_users_on_church_id_and_is_church_admin"
    t.index ["church_id", "is_owner"], name: "index_users_on_church_id_and_is_owner", where: "is_owner = 1"
    t.index ["church_id"], name: "index_users_on_church_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["email_bounce_status"], name: "index_users_on_email_bounce_status"
    t.index ["email_suppressed"], name: "index_users_on_email_suppressed"
  end

  add_foreign_key "categories", "churches"
  add_foreign_key "checklist_completions", "checklist_items"
  add_foreign_key "checklist_completions", "need_signups"
  add_foreign_key "checklist_items", "checklists"
  add_foreign_key "checklists", "churches"
  add_foreign_key "checklists", "users", column: "created_by_id"
  add_foreign_key "need_signups", "needs"
  add_foreign_key "need_signups", "users"
  add_foreign_key "needs", "categories"
  add_foreign_key "needs", "checklists"
  add_foreign_key "needs", "churches"
  add_foreign_key "needs", "needs", column: "parent_need_id"
  add_foreign_key "needs", "users", column: "approved_by_id"
  add_foreign_key "needs", "users", column: "completed_by_id"
  add_foreign_key "needs", "users", column: "creator_id"
  add_foreign_key "notification_preferences", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "room_bookings", "needs"
  add_foreign_key "room_bookings", "rooms"
  add_foreign_key "room_bookings", "users", column: "approved_by_id"
  add_foreign_key "room_bookings", "users", column: "requested_by_id"
  add_foreign_key "rooms", "churches"
  add_foreign_key "sessions", "users"
  add_foreign_key "subscriptions", "churches"
  add_foreign_key "users", "churches"
end
