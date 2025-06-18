FactoryBot.define do
  factory :point_card do
    association :giver, factory: :user
    title { "My Awesome Point Card" }
    max_point { 100 }
    current_round { 1 }
    # pin_code は before_create コールバックで生成されるため不要
  end
end