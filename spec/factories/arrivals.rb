FactoryBot.define do
  factory :arrival do
    time Faker::Time.between(DateTime.now - 1, DateTime.now)
    bus
    bus_station
  end
end
