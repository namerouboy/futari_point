FactoryBot.define do
  factory :point_record do
    association :point_card
    association :added_by_user, factory: :user
    points { 1 }
  end
end