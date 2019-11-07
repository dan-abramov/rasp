class PagesController < ApplicationController
  include SearchHelper
  include ApplicationHelper

  autocomplete :bus_station, :name

  def results
  end

  def get_schedule
    respond_to do |format|
      format.js
    end
    if route_params['day'] == 'сегодня'
      day = { today: Time.now.utc + 3.hours }
    elsif route_params['day'] == 'завтра'
      day = { tomorrow: Time.now.utc + 3.hours + 1.day }
    end
    find_schedule(route_params['from'], route_params['to'], day)
  end


  def route_params
    params.require(:route).permit(:from, :to, :day)
  end

  def find_schedule(from, to, day)
    first_station_id = BusStation.where(name: from)[0].id
    second_station_id = BusStation.where(name: to)[0].id

    @schedule = find_in_yandex(first_station_id, second_station_id, day)

    # @schedule = return_schedule(day, first_station_id, second_station_id)
  end


  def return_schedule(day, first_station_id, second_station_id)
    schedule = []
    part_of_week = define_part_of_week(day.first[1])

    Route.where(day: part_of_week).each do |route|
      arrivals = route.arrivals.sort_by(&:created_at)
      route_bus_stations = arrivals.pluck(:bus_station_id)

      second_station_id_index = route_bus_stations.index(second_station_id)
      next unless second_station_id_index
      route_bus_stations = route_bus_stations[0..second_station_id_index]
      first_station_id_rindex = route_bus_stations.rindex(first_station_id)
      next unless first_station_id_rindex

      departure = arrivals[first_station_id_rindex].time
      arrival = arrivals[second_station_id_index].time
      if day[:today]
        if (Time.now.utc + 3.hours).strftime('%H:%M') <= departure.strftime('%H:%M')
          schedule << [route.bus_number, departure.strftime('%H:%M'), arrival.strftime('%H:%M')]
        end
      elsif day[:tomorrow]
        schedule << [route.bus_number, departure.strftime('%H:%M'), arrival.strftime('%H:%M')]
      end
    end
    if schedule == []
      schedule = nil
    else
      schedule = schedule.sort_by { |time| time[1] }
    end
  end
end
