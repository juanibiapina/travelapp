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

ActiveRecord::Schema[8.0].define(version: 2025_06_19_053544) do
  create_table "accommodations", force: :cascade do |t|
    t.string "title", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.integer "place_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["place_id"], name: "index_accommodations_on_place_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "provider"
    t.string "uid"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_accounts_on_email", unique: true
    t.index ["provider", "uid"], name: "index_accounts_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "invites", force: :cascade do |t|
    t.integer "trip_id", null: false
    t.string "token", null: false
    t.boolean "active", default: true, null: false
    t.datetime "expires_at"
    t.integer "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_invites_on_created_by_id"
    t.index ["token"], name: "index_invites_on_token", unique: true
    t.index ["trip_id"], name: "index_invites_on_trip_id"
  end

  create_table "places", force: :cascade do |t|
    t.string "name"
    t.integer "trip_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.index ["trip_id"], name: "index_places_on_trip_id"
  end

  create_table "transport_users", force: :cascade do |t|
    t.integer "transport_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transport_id", "user_id"], name: "index_transport_users_on_transport_id_and_user_id", unique: true
    t.index ["transport_id"], name: "index_transport_users_on_transport_id"
    t.index ["user_id"], name: "index_transport_users_on_user_id"
  end

  create_table "transports", force: :cascade do |t|
    t.string "name", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.integer "trip_id", null: false
    t.integer "origin_place_id", null: false
    t.integer "destination_place_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["destination_place_id"], name: "index_transports_on_destination_place_id"
    t.index ["origin_place_id"], name: "index_transports_on_origin_place_id"
    t.index ["trip_id"], name: "index_transports_on_trip_id"
  end

  create_table "trip_memberships", force: :cascade do |t|
    t.integer "trip_id", null: false
    t.integer "user_id", null: false
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "starting_place_id"
    t.index ["starting_place_id"], name: "index_trip_memberships_on_starting_place_id"
    t.index ["trip_id", "user_id"], name: "index_trip_memberships_on_trip_id_and_user_id", unique: true
    t.index ["trip_id"], name: "index_trip_memberships_on_trip_id"
    t.index ["user_id"], name: "index_trip_memberships_on_user_id"
  end

  create_table "trips", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "picture"
  end

  add_foreign_key "accommodations", "places"
  add_foreign_key "accounts", "users"
  add_foreign_key "invites", "trips"
  add_foreign_key "invites", "users", column: "created_by_id"
  add_foreign_key "places", "trips"
  add_foreign_key "transport_users", "transports"
  add_foreign_key "transport_users", "users"
  add_foreign_key "transports", "places", column: "destination_place_id"
  add_foreign_key "transports", "places", column: "origin_place_id"
  add_foreign_key "transports", "trips"
  add_foreign_key "trip_memberships", "places", column: "starting_place_id"
  add_foreign_key "trip_memberships", "trips"
  add_foreign_key "trip_memberships", "users"
end
