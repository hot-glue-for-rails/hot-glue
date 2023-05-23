FactoryBot.define do
  factory :dfg do
    user { build(:user) }
    name { FFaker.name }
    cantelope { build(:cantelope) }
  end
end
