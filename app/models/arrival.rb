class Arrival < ApplicationRecord
  validates  :time, presence: true

  belongs_to :bus_station
  belongs_to :route
end
