FactoryBot.define do
  factory :hgi do
    name { FFaker::Name }
    how_many {rand(4)}
    hello { FFaker::Name }
  end
end
