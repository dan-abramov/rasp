class CreateArrivals < ActiveRecord::Migration[5.1]
  def change
    create_table :arrivals do |t|
      t.time       :time, presence: true
      t.belongs_to :bus,         index: true
      t.belongs_to :bus_station, index: true
      t.timestamps
    end
  end
end
