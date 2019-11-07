module SearchHelper
  def request_made_in_evening
    if (Time.now.utc + 5.hours).day == (Time.now.utc + 3.hours + 1.day).day
      true
    else
      false
    end
  end

  def find_in_yandex(first_station, second_station, day)
    schedule = []
    if day[:today]
      routes = get_routes_from_yandex(first_station, second_station, day[:today])
      day = day[:today]

      if routes.get.body['segments']
        routes.get.body['segments'].each do |route|
          departure_time = route['departure'].split('T')[1].split('+')[0]
          if departure_time > Time.now.utc + 3.hours
            Route.save_new(route, day)
            arrival_time = route['arrival'].split('T')[1].split('+')[0]
            arrival_time = "#{arrival_time.split(':')[0]}:#{arrival_time.split(':')[1]}"
            bus_number = route['thread']['number']
            departure_time = "#{departure_time.split(':')[0]}:#{departure_time.split(':')[1]}"
            schedule << [bus_number, departure_time, arrival_time]
          else
            next
          end
        end
      else
        schedule = nil
      end
    elsif day[:tomorrow]
      routes = get_routes_from_yandex(first_station, second_station, day[:tomorrow])
      day = day[:tomorrow]

      if routes.get.body['segments']
        routes.get.body['segments'].each do |route|
          departure_time = route['departure'].split('T')[1].split('+')[0]
          Route.save_new(route, day)
          arrival_time = route['arrival'].split('T')[1].split('+')[0]
          arrival_time = "#{arrival_time.split(':')[0]}:#{arrival_time.split(':')[1]}"
          bus_number = route['thread']['number']
          departure_time = "#{departure_time.split(':')[0]}:#{departure_time.split(':')[1]}"
          schedule << [bus_number, departure_time, arrival_time]
        end
      else
        schedule = nil
      end
    end

    schedule
  end

  def get_routes_from_yandex(first_station, second_station, day)
    url = "https://api.rasp.yandex.net/v3.0/search/?from=#{first_station}&to=#{second_station}&apikey=#{Rails.application.secrets[:yandex_rasp]}
           &format=json&date=#{day.to_s.split.first}"
    routes = Faraday.new(url: url) do |faraday|
      faraday.request  :url_encoded
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter  Faraday.default_adapter
    end
    routes
  end
end
