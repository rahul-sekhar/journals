require 'factory_girl'

FactoryGirl.define do
  factory :teacher do
    sequence(:email){ |n| "email#{n}@server.com"}
    sequence(:last_name){ |n| "Teacher#{n}" }
    password "pass"
  end

  factory :student do
    sequence(:email){ |n| "student_email#{n}@server.com"}
    sequence(:last_name){ |n| "Student#{n}" }
    password "pass"
  end

  factory :guardian do
    sequence(:email){ |n| "guardian_email#{n}@server.com"}
    sequence(:last_name){ |n| "Guardian#{n}" }
    password "pass"
    student
  end

  factory :post do
    title "Some Post"
    user { create(:teacher).user }
  end

  factory :tag do
    sequence(:name){ |n| "tag#{n}"}
  end

  factory :comment do
    post
    user { create(:teacher).user }
    content "Some content"
  end

  factory :student_observation do
    post
    student
    content "Some content"
  end
end