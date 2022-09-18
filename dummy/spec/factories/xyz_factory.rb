FactoryBot.define do
  factory :xyz do
    user { build(:user) }
  end
end
