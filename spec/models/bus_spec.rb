require 'rails_helper'

RSpec.describe Bus, type: :model do
  let(:bus_station)        { create(:bus_station) }
  let(:second_bus_station) { create(:bus_station) }
  let(:bus)                { create(:bus) }
  let(:route)              { create(:route, bus: bus) }
  let!(:arrival)           { create(:arrival, bus_station: bus_station, bus: bus, route: route) }
  let!(:second_arrival)    { create(:arrival, bus_station: second_bus_station, bus: bus, route: route) }

  it 'has association with bus_stations' do
    expect(bus.bus_stations.first).to eq bus_station
    expect(bus.bus_stations.length).to eq 2
  end


  it 'has many arrivals' do
    expect(bus.arrivals.length).to eq 2
  end
end
