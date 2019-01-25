require 'rails_helper'

RSpec.describe Route, type: :model do
  let(:bus)   { create(:bus) }
  let(:route) { create(:route, bus: bus) }

  let(:bus_stations)  { create_list(:bus_station, 2) }

  let!(:first_arrival)     { create(:arrival, bus_station: bus_stations.first, bus: bus, route: route) }
  let!(:second_arrival)    { create(:arrival, bus_station: bus_stations.last, bus: bus, route: route) }

  it 'has association with bus' do
    expect(route.bus).to eq bus
  end

  it 'has assosiations with arrivals' do
    expect(route.arrivals.first).to eq first_arrival
    expect(route.arrivals.length).to eq 2
  end

  it 'has assosiations with bus_stations' do
    expect(route.bus_stations.first).to eq bus_stations[0]
    expect(route.bus_stations.length).to eq 2
  end
end
