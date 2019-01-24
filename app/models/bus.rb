class Bus < ApplicationRecord
  validates :number, presence: true
  has_many :arrivals
  has_many :bus_stations, through: :arrivals
end
