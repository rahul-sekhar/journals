require 'factory_girl'

FactoryGirl.define do
  factory :user do
    sequence(:email){ |n| "email#{n}@server.com"}
    password "pass"
  end

  factory :teacher do
    sequence(:email){ |n| "email#{n}@server.com"}
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