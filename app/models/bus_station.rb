class BusStation < ApplicationRecord
  validates :name, presence: true
  
  has_many :arrivals
  has_many :buses, through: :arrivals
end
