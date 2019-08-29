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

ActiveRecord::Schema.define(version: 20190124142628) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "arrivals", force: :cascade do |t|
    t.time "time"
    t.string "bus_station_id"
    t.string "route_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bus_station_id"], name: "index_arrivals_on_bus_station_id"
    t.index ["route_id"], name: "index_arrivals_on_route_id"
  end

  create_table "bus_stations", id: false, force: :cascade do |t|
    t.string "id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_bus_stations_on_id", unique: true
  end

  create_table "routes", id: false, force: :cascade do |t|
    t.string "id", null: false
    t.string "day", null: false
    t.string "bus_number", null: false
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_routes_on_id", unique: true
  end

end
