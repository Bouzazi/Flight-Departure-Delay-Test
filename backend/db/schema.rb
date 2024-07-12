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

ActiveRecord::Schema[7.1].define(version: 2024_07_08_010200) do
  create_table "airlines", primary_key: "code", id: :string, force: :cascade do |t|
    t.string "label"
  end

  create_table "airports", primary_key: "code", id: :string, force: :cascade do |t|
    t.string "label"
  end

  create_table "flights", id: :string, force: :cascade do |t|
    t.string "flight_number", null: false
    t.string "airline", null: false
    t.string "origin", null: false
    t.string "destination", null: false
    t.datetime "scheduled_departure_at", null: false
    t.datetime "actual_departure_at"
    t.datetime "scheduled_arrival_at", null: false
    t.datetime "actual_arrival_at"
    t.datetime "estimated_arrival_at"
    t.text "marketing_flights", default: "[]"
    t.text "delays", default: "[]"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_number", "scheduled_departure_at", "origin"], name: "index_flights_on_unique_flight", unique: true
  end

end
