class Route < ApplicationRecord
  belongs_to :bus
  has_many :arrivals
  has_many :bus_stations, through: :arrivals
end
