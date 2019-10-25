class Arrival < ApplicationRecord
  validates  :time, presence: true

  belongs_to :bus_station
  belongs_to :route

  def self.save_route_arrivals(route_id)
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
end
