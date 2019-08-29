class Route < ApplicationRecord
  self.primary_key = 'id'

  has_many :arrivals
  has_many :bus_stations, through: :arrivals
end
