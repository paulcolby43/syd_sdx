# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160512182412) do

  create_table "access_tokens", force: true do |t|
    t.string   "token_string", limit: nil
    t.integer  "user_id"
    t.datetime "expiration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true

  create_table "companies", force: true do |t|
    t.string "name"
    t.string "dragon_api"
    t.string "leads_online_store_id"
    t.string "leads_online_ftp_username"
    t.string "leads_online_ftp_password"
  end

  create_table "cust_pic_files", force: true do |t|
    t.string   "name"
    t.string   "file"
    t.integer  "user_id"
    t.string   "customer_number"
    t.string   "location"
    t.string   "event_code"
    t.integer  "cust_pic_id"
    t.boolean  "hidden",          default: false
    t.integer  "blob_id"
    t.string   "vin_number"
    t.string   "tag_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "yard_id"
  end

  create_table "image_files", force: true do |t|
    t.string   "name"
    t.string   "file"
    t.integer  "user_id"
    t.string   "ticket_number"
    t.string   "customer_number"
    t.string   "branch_code"
    t.string   "location"
    t.string   "event_code"
    t.integer  "image_id"
    t.string   "container_number"
    t.string   "booking_number"
    t.string   "contract_number"
    t.boolean  "hidden",            default: false
    t.integer  "blob_id"
    t.string   "tare_seq_nbr"
    t.string   "commodity_name"
    t.decimal  "weight"
    t.string   "customer_name"
    t.string   "tag_number"
    t.string   "vin_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "yard_id"
    t.string   "contract_verbiage"
  end

  create_table "user_settings", force: true do |t|
    t.boolean  "show_thumbnails",          default: false
    t.string   "table_name",               default: "images"
    t.boolean  "show_customer_thumbnails", default: false
    t.boolean  "show_ticket_thumbnails",   default: false
    t.integer  "device_group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.string   "email"
    t.string   "company_name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "customer_guid"
    t.string   "yard_id"
    t.integer  "company_id"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.boolean  "email_confirmed", default: false
    t.string   "confirm_token"
  end

end
