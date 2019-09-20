class PagesController < ApplicationController
  autocomplete :bus_station, :name


  def schedule
  end

  def results
    @schedule = session[:schedule]
  end

  def stations
    # stations = Nokogiri::HTML(open("https://rasp.yandex.ru/thread/17_0_f9739655t9822055_r4253_1?departure=2019-08-14")).css('.ThreadTable__wrapperInner a')
    # stations.each do |station|
    #   id = station['href'][/\d+/]
    #   name = station.text
    #
    #   begin
    #     create_station = BusStation.new({ id: id, name: name })
    #     create_station.save
    #   rescue ActiveRecord::RecordNotUnique
    #     next
    #   end
    # end
  end

  def arrivals
    # doc = Nokogiri::HTML(open("https://rasp.yandex.ru/thread/11_4_f9739657t9755974_r4245_1?departure=2019-08-20"))
    # @stations = []
    # doc.css('.ThreadTable__rowStation').each do |tr|
    #   station = tr.css('.ThreadTable__station')
    #   station_id = ''
    #   station.css('a').each do |link|
    #     station_id = link['href'][/\d+/].to_i
    #   end
    #
    #   if tr.css('.ThreadTable__arrival').text == '—'
    #     time = tr.css('.ThreadTable__departure').text
    #   else
    #     time = tr.css('.ThreadTable__arrival').text
    #   end
    #
    #   @stations << [station_id, station.text, time]
    #   arrival = Arrival.new({ time: time, bus_id: 4, bus_station_id: station_id, route_id: 3})
    #   arrival.save
    # end
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
    @days = define_days
    @days.each do |day, day_type|
      day = day.to_s
      @schedule << return_schedule(day, day_type, from_id, to_id)
    end
    session[:schedule] = @schedule
    redirect_to action: 'results'
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

    if Date.tomorrow.day == (Time.now + 12.hours).day #if day ends web-service shows schedule on next day
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

  # def find_buses(from, to)
  #   @schedule = []
  #   station_from_id = BusStation.where(name: from)[0].id
  #   station_to_id = BusStation.where(name: to)[0].id
  #
  #   Route.all.each do |route|
  #     route_bus_stations = route.arrivals.sort_by(&:time).pluck(:bus_station_id)
  #
  #     from_index = route_bus_stations.index(station_from_id)
  #     to_index = route_bus_stations.index(station_to_id)
  #
  #     if from_index && to_index
  #       if from_index < to_index
  #
  #         time_from = route.arrivals.where(bus_station_id: station_from_id)[0].time
  #         time_to = route.arrivals.where(bus_station_id: station_to_id)[0].time
  #         @schedule << [time_from.strftime('%H:%M'), time_to.strftime('%H:%M'), Bus.find(route.bus_id).number]
  #       end
  #     end
  #   end
  #   @schedule = @schedule.sort_by do |time|
  #     time.first
  #   end
  #   session[:schedule] = @schedule
  #   redirect_to action: 'results'
  # end
end
