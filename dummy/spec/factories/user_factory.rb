FactoryBot.define do
  factory :user do
    email { FFaker::Internet.email }
    password { "password" }
    password_confirmation { "password" }
    family { build(:family) }
  end
end
