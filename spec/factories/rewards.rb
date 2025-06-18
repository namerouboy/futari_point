FactoryBot.define do
  factory :reward do
    association :point_card
    name { "Test Reward" }
    message { "You got a reward!" }
    required_points { 10 }
  end
end