class CreateArrivals < ActiveRecord::Migration[5.1]
  def change
    create_table :arrivals do |t|
      t.time :time, presence: true
      t.string :bus_station_id, index: true
      t.string :route_id, index: true
      t.timestamps
    end
  end
end
