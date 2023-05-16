FactoryBot.define do
  factory :pet do
    human {create(:human)}
  end
end
