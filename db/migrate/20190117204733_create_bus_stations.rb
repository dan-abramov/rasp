class CreateBusStations < ActiveRecord::Migration[5.1]
  def change
    create_table :bus_stations do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
