require 'rails_helper'

RSpec.describe Arrival, type: :model do
  let(:bus_station) { create(:bus_station) }
  let(:bus)         { create(:bus) }
  let(:route)       { create(:route, bus: bus) }
  let(:arrival)     { create(:arrival, bus_station: bus_station, bus: bus, route: route) }

  it 'has associations with bus, bus_station and route' do
    expect(arrival.bus).to eq bus
    expect(arrival.bus_station).to eq bus_station
    expect(arrival.route).to eq route
  end
end
