class PagesController < ApplicationController
  require 'nokogiri'
  require 'open-uri'
  require 'net/https'
  require 'faraday'
  require 'json'

  def schedule
    url = "https://api.rasp.yandex.net/v3.0/search/?from=s9739657&to=s9871163&apikey=#{Rails.application.secrets[:yandex_rasp]}&format=json"

    # find_all_routes(url)
  end

  def results
    @schedule = session[:schedule]
  end

  def stations
    stations = Nokogiri::HTML(open("https://rasp.yandex.ru/thread/17_0_f9739655t9822055_r4253_1?departure=2019-08-14")).css('.ThreadTable__wrapperInner a')
    stations.each do |station|
      id = station['href'][/\d+/]
      name = station.text

      begin
        create_station = BusStation.new({ id: id, name: name })
        create_station.save
      rescue ActiveRecord::RecordNotUnique
        next
      end
    end
  end

  def arrivals
    doc = Nokogiri::HTML(open("https://rasp.yandex.ru/thread/11_4_f9739657t9755974_r4245_1?departure=2019-08-20"))
    @stations = []
    doc.css('.ThreadTable__rowStation').each do |tr|
      station = tr.css('.ThreadTable__station')
      station_id = ''
      station.css('a').each do |link|
        station_id = link['href'][/\d+/].to_i
      end

      if tr.css('.ThreadTable__arrival').text == '—'
        time = tr.css('.ThreadTable__departure').text
      else
        time = tr.css('.ThreadTable__arrival').text
      end

      @stations << [station_id, station.text, time]
      arrival = Arrival.new({ time: time, bus_id: 4, bus_station_id: station_id, route_id: 3})
      arrival.save
    end
  end

  def get_schedule
    find_schedule(route_params['from'], route_params['to'])
  end

  private

  def route_params
    params.require(:route).permit(:from, :to)
  end

  def find_schedule(from, to)
    @schedule = []
    from_id = BusStation.where(name: from)[0].id
    to_id = BusStation.where(name: to)[0].id

    Route.all.each do |route|
      bus_stations_array = route.arrivals.sort_by(&:time).pluck(:bus_station_id)

      from_id_index = bus_stations_array.index(from_id)
      to_id_index = bus_stations_array.index(to_id)
      if from_id_index && to_id_index
        if from_id_index < to_id_index
          departure = route.arrivals.where(bus_station_id: from_id)[0].time
          arrival = route.arrivals.where(bus_station_id: to_id)[0].time
          @schedule << [route.bus_number, departure, arrival]
        end
      end
    end
    @schedule = @schedule.sort_by do |time|
      time.first
    end
    session[:schedule] = @schedule
    redirect_to action: 'results'
  end

  def find_all_routes(url)

    response = Faraday.new(url: url) do |faraday|
      faraday.request  :url_encoded
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter  Faraday.default_adapter
    end

    response.get.body['segments'].each do |bus|
      begin
        new_route = Route.new({ id: bus['thread']['uid'], bus_number: bus['thread']['number'], title: bus['thread']['title'], day: 'weekday' } )
        new_route.save

        url = "https://api.rasp.yandex.net/v3.0/thread/?apikey=#{Rails.application.secrets[:yandex_rasp]}&format=json&uid=#{bus['thread']['uid']}&lang=ru_RU&show_systems=all"

        save_schedule(url, new_route)
      rescue ActiveRecord::RecordNotUnique
      end
    end
  end

  def save_schedule(url, new_route)
    route = Faraday.new(url: url) do |faraday|
      faraday.request  :url_encoded
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter  Faraday.default_adapter
    end

    route.get.body['stops'].each do |arrival|
      @arrival = arrival
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

      new_arrival = Arrival.new({ time: time, bus_station_id: bus_station.id, route_id: new_route.id })
      new_arrival.save
    end
  end

  def find_buses(from, to)
    @schedule = []
    station_from_id = BusStation.where(name: from)[0].id
    station_to_id = BusStation.where(name: to)[0].id

    Route.all.each do |route|
      bus_stations_array = route.arrivals.sort_by(&:time).pluck(:bus_station_id)

      from_index = bus_stations_array.index(station_from_id)
      to_index = bus_stations_array.index(station_to_id)

      if from_index && to_index
        if from_index < to_index

          time_from = route.arrivals.where(bus_station_id: station_from_id)[0].time
          time_to = route.arrivals.where(bus_station_id: station_to_id)[0].time
          @schedule << [time_from.strftime('%H:%M'), time_to.strftime('%H:%M'), Bus.find(route.bus_id).number]
        end
      end
    end
    @schedule = @schedule.sort_by do |time|
      time.first
    end
    session[:schedule] = @schedule
    redirect_to action: 'results'
  end
end
