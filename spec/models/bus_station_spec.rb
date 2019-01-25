require 'rails_helper'

RSpec.describe BusStation, type: :model do
  let(:bus_station)  { create(:bus_station) }
  let(:buses)        { create_list(:bus, 2) }
  let(:first_route)  { create(:route, bus: buses.first) }
  let(:second_route) { create(:route, bus: buses.first) }

  let!(:first_arrival)     { create(:arrival, bus_station: bus_station, bus: buses.first, route: first_route) }
  let!(:second_arrival)    { create(:arrival, bus_station: bus_station, bus: buses.last, route: second_route) }

  it 'has many arrivals' do
    expect(bus_station.arrivals.length).to eq 2
  end

  it 'has assosiations with buses' do
    expect(bus_station.buses.first).to eq buses[0]
    expect(bus_station.buses.length).to eq 2
  end
end
