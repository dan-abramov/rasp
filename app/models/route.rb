class Route < ApplicationRecord
  self.primary_key = 'id'

  has_many :arrivals, dependent: :destroy
  has_many :bus_stations, through: :arrivals
end
