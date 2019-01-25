FactoryBot.define do
  factory :bus do
    number Faker::Number.between(1, 10)
  end
end
