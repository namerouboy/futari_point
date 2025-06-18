FactoryBot.define do
  factory :notification do
    association :user
    association :point_card
    content { "Test Notification" }
  end
end