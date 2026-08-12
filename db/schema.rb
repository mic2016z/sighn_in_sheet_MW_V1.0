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

ActiveRecord::Schema[8.1].define(version: 2026_08_12_070654) do
  create_table "locations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "organisation_id", null: false
    t.text "programs"
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_locations_on_organisation_id"
    t.index ["slug"], name: "index_locations_on_slug", unique: true
  end

  create_table "organisations", force: :cascade do |t|
    t.string "contact_email"
    t.datetime "created_at", null: false
    t.integer "default_auto_close_hours", default: 4, null: false
    t.string "name", null: false
    t.string "timezone", default: "Australia/Sydney", null: false
    t.datetime "updated_at", null: false
  end

  create_table "people", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "full_name", null: false
    t.integer "organisation_id", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id", "full_name"], name: "index_people_on_organisation_id_and_full_name"
    t.index ["organisation_id"], name: "index_people_on_organisation_id"
  end

  create_table "visits", force: :cascade do |t|
    t.boolean "auto_closed", default: false, null: false
    t.datetime "created_at", null: false
    t.string "edited_by"
    t.integer "location_id", null: false
    t.integer "organisation_id", null: false
    t.integer "person_id", null: false
    t.string "person_name", null: false
    t.string "program"
    t.text "signature_data"
    t.datetime "signed_in_at", null: false
    t.datetime "signed_out_at"
    t.datetime "updated_at", null: false
    t.index ["location_id", "signed_in_at"], name: "index_visits_on_location_id_and_signed_in_at"
    t.index ["location_id"], name: "index_visits_on_location_id"
    t.index ["organisation_id", "signed_out_at"], name: "index_visits_on_organisation_id_and_signed_out_at"
    t.index ["organisation_id"], name: "index_visits_on_organisation_id"
    t.index ["person_id"], name: "index_visits_on_person_id"
  end

  add_foreign_key "locations", "organisations"
  add_foreign_key "people", "organisations"
  add_foreign_key "visits", "locations"
  add_foreign_key "visits", "organisations"
  add_foreign_key "visits", "people"
end
