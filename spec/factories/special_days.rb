FactoryBot.define do
  factory :special_day do
    association :point_card
    date { Date.tomorrow }
    multiplier { 2 }
  end
end