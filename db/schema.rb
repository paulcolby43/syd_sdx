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

ActiveRecord::Schema.define(version: 20160404173948) do

  create_table "access_tokens", force: true do |t|
    t.string   "token_string", limit: nil
    t.integer  "user_id"
    t.datetime "expiration"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "username",      limit: nil
    t.string   "password_hash", limit: nil
    t.string   "password_salt", limit: nil
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
  end

end
