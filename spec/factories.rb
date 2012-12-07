require 'factory_girl'

FactoryGirl.define do
  factory :user do
    sequence(:username){ |n| "user#{n}"}
    password "pass"
    association :profile, factory: :teacher_profile
  end

  factory :teacher_profile do
    sequence(:last_name){ |n| "Teacher#{n}" }
    password "pass"
  end
end