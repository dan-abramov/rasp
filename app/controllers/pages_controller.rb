class PagesController < ApplicationController
  autocomplete :bus_station, :name

  def results
    @schedule = session[:schedule]
  end

  def get_schedule
    respond_to do |format|
      format.js
    end
    find_schedule(route_params['from'], route_params['to'])
  end

  private

  def route_params
    params.require(:route).permit(:from, :to)
  end

  def find_schedule(from, to)
    first_station_id = BusStation.where(name: from)[0].id
    second_station_id = BusStation.where(name: to)[0].id

    find_in_yandex(first_station_id, second_station_id)
    # @schedule = []
    # @days = define_days
    # @days.each do |day, day_type|
    #   day = day.to_s
    #   @schedule << return_schedule(day, day_type, first_station_id, second_station_id)
    # end
    # session[:schedule] = @schedule
  end

  def find_in_yandex(first_station, second_station)
    @schedule = [[]]
    url = "https://api.rasp.yandex.net/v3.0/search/?from=#{first_station}&to=#{second_station}&apikey=#{Rails.application.secrets[:yandex_rasp]}
           &format=json&date=#{(Time.now.utc + 3*60*60).to_s.split.first}"

    routes = Faraday.new(url: url) do |faraday|
      faraday.request  :url_encoded
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter  Faraday.default_adapter
    end

    routes.get.body['segments'].each do |route|
      departure_time = route['departure'].split('T')[1].split('+')[0]
      if departure_time > Time.now.utc + 3.hours && departure_time <= Time.now.utc + 5.hours
        save_route(route)
        arrival_time = route['arrival'].split('T')[1].split('+')[0]
        arrival_time = "#{arrival_time.split(':')[0]}:#{arrival_time.split(':')[1]}"
        bus_number = route['thread']['number']
        departure_time = "#{departure_time.split(':')[0]}:#{departure_time.split(':')[1]}"
        @schedule[0] << [bus_number, departure_time, arrival_time]
      else
        next
      end
    end
  end

  def save_route(route)
    begin
      new_route = Route.new({ id: route['thread']['uid'], bus_number: route['thread']['number'], title: route['thread']['title'], day: 'weekday' })
      new_route.save
      save_route_arrivals(route['thread']['uid'])
    rescue ActiveRecord::RecordNotUnique
      existing_route = Route.find(route['thread']['uid'])
      if existing_route.created_at < (Time.now.utc + 3.hours) - 2.days
        existing_route.destroy!
        new_route = Route.new({ id: route['thread']['uid'], bus_number: route['thread']['number'], title: route['thread']['title'], day: 'weekday' })
        new_route.save
        save_route_arrivals(route['thread']['uid'])
      end
    end
  end

  def save_route_arrivals(route_id)
    url = "https://api.rasp.yandex.net/v3.0/thread/?apikey=#{Rails.application.secrets[:yandex_rasp]}&format=json&uid=#{route_id}&lang=ru_RU&show_systems=all"

    route = Faraday.new(url: url) do |faraday|
      faraday.request  :url_encoded
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter  Faraday.default_adapter
    end

    route.get.body['stops'].each do |arrival|
      if arrival['departure']
        time = arrival['departure'].split(' ')[1]
      else
        time = arrival['arrival'].split(' ')[1]
      end

      begin
        bus_station = BusStation.find(arrival['station']['code'])
      rescue ActiveRecord::RecordNotFound
        bus_station = BusStation.new({ id: arrival['station']['code'], name: arrival['station']['title'] })
        bus_station.save
      end

      new_arrival = Arrival.new({ time: time, bus_station_id: bus_station.id, route_id: route_id })
      new_arrival.save
    end
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
