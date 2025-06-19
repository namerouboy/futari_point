FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    name { "Test User" }
    password { 'password' }
    password_confirmation { 'password' }

    trait :confirmed do
      confirmed_at { Time.current }
    end
  end
end