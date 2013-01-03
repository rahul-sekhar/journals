require 'factory_girl'

FactoryGirl.define do
  factory :user do
    sequence(:username){ |n| "user#{n}"}
    password "pass"
    association :profile, factory: :teacher
  end

  factory :teacher do
    sequence(:last_name){ |n| "Teacher#{n}" }
    password "pass"
  end

  factory :post do
    title "Some Post"
    user
  end

  factory :tag do
    sequence(:name){ |n| "tag#{n}"}
  end
end