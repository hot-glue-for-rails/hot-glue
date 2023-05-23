FactoryBot.define do
  factory :cantelope, class: Fruits::Cantelope do
    name { FFaker.name }
    _a_show_only_field { FFaker.name }
  end
end
