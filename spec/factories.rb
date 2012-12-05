require 'factory_girl'

FactoryGirl.define do
  factory :user do
    sequence(:username){ |n| "user#{n}"}
    password "pass"

    factory :user_rahul do
      username "rahul"
      password "test-pass"
    end

    factory :user_shalu do
      username "shalu"
      password "other-pass"      
    end
  end
end