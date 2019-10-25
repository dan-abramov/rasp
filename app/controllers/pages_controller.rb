class PagesController < ApplicationController
  include SearchHelper

  autocomplete :bus_station, :name
  def results
    @schedule = session[:schedule]
  end

  def get_schedule
    respond_to do |format|
      format.js
    end
    if route_params['day'] == 'сегодня'
      day = Time.now.utc + 3.hours
    elsif route_params['day'] == 'завтра'
      day = Time.now.utc + 3.hours + 1.day
    end
    find_schedule(route_params['from'], route_params['to'], day)
  end

  private

  def route_params
    params.require(:route).permit(:from, :to, :day)
  end

  def find_schedule(from, to, day)
    first_station_id = BusStation.where(name: from)[0].id
    second_station_id = BusStation.where(name: to)[0].id

    @schedule = find_in_yandex(first_station_id, second_station_id, day)
    unless @schedule #а что если придет часть информации только?
    end
    # @schedule = []
    # @days = define_days
    # @days.each do |day, day_type|
    #   day = day.to_s
    #   @schedule << return_schedule(day, day_type, first_station_id, second_station_id)
    # end
    # session[:schedule] = @schedule
  end

  def define_days #this method helps to define: need user to get schedule on next day or not
    needed_days = {}
    if Time.now.on_weekday?
      needed_days[:current_day] = 'weekday'
    elsif Time.now.saturday?
      needed_days[:current_day] = 'saturday'
    elsif Time.now.sunday?
      needed_days[:current_day] = 'sunday'
    end

    if Date.tomorrow.day == (Time.now + 2.hours).day #if day ends web-service shows schedule on next day
      if Date.tomorrow.on_weekday? #we need to know weekday for database
        needed_days[:next_day] = 'weekday'
      elsif Date.tomorrow.saturday?
        needed_days[:next_day] = 'saturday'
      elsif Date.tomorrow.sunday?
        needed_days[:next_day] = 'sunday'
      end
    end
    needed_days
  end

  def return_schedule(day, day_type, from_id, to_id)
    schedule = []
    Route.where(day: day_type).each do |route|
      route_bus_stations = route.arrivals.sort_by(&:created_at).pluck(:bus_station_id)

      from_id_index = route_bus_stations.index(from_id)
      to_id_index = route_bus_stations.index(to_id)

      if from_id_index && to_id_index
        if from_id_index < to_id_index

          departure = route.arrivals.where(bus_station_id: from_id)[0].time
          arrival = route.arrivals.where(bus_station_id: to_id)[0].time
          if day == 'current_day'
            if Time.now.strftime('%H:%M') <= departure.strftime('%H:%M') && departure.strftime('%H:%M') <= (Time.now + 2.hours).strftime('%H:%M')
              schedule << [route.bus_number, departure.strftime('%H:%M'), arrival.strftime('%H:%M')]
            end
          elsif day == 'next_day'
            if departure.strftime('%H:%M') <= '09:00'
              schedule << [route.bus_number, departure.strftime('%H:%M'), arrival.strftime('%H:%M')]
            end
          end
        end
      end
    end
    schedule = schedule.sort_by { |time| time[1] }
  end
end
