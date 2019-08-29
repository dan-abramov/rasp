class BusStation < ApplicationRecord
  validates :name, presence: true
  self.primary_key = 'id'
  
  has_many :arrivals
end
