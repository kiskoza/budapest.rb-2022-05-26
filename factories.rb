require 'factory_bot'

FactoryBot.define do
  factory :child do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end
end
