class CreateBusStations < ActiveRecord::Migration[5.1]
  def change
    create_table :bus_stations, id: false do |t|
      t.string :id, null: false
      t.string :name, null: false
      t.timestamps
    end

    add_index :bus_stations, :id, unique: true
  end
end
