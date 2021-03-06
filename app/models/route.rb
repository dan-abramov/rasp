class Route < ApplicationRecord
  include ::ModelHelper
  self.primary_key = 'id'

  has_many :arrivals, dependent: :destroy
  has_many :bus_stations, through: :arrivals

  def self.save_new(route, day)
    begin
      ApplicationRecord.transaction do
        Route.create!({ id: route['thread']['uid'], bus_number: route['thread']['number'], title: route['thread']['title'], day: define_part_of_week(day) })
        Arrival.save_route_arrivals(route['thread']['uid'])
      end
    rescue ActiveRecord::RecordNotUnique
      existing_route = Route.find(route['thread']['uid'])
      if existing_route.created_at < (Time.now.utc + 3.hours) - 2.days
        existing_route.destroy!
        ApplicationRecord.transaction do
          Route.create!({ id: route['thread']['uid'], bus_number: route['thread']['number'], title: route['thread']['title'], day: define_part_of_week(day) })
          Arrival.save_route_arrivals(route['thread']['uid'])
        end
      end
    end
  end
end
