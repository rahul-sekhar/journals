require 'factory_girl'

FactoryGirl.define do
  factory :teacher do
    sequence(:name){ |n| "Teacher#{n}" }

    factory :teacher_with_user do
      sequence(:email){ |n| "teacher#{n}@mail.com" }
    end
  end

  factory :student do
    sequence(:name){ |n| "Student#{n}" }

    factory :student_with_user do
      sequence(:email){ |n| "student#{n}@mail.com" }
    end
  end

  factory :guardian do
    sequence(:name){ |n| "Guardian#{n}" }
    students { [create(:student)] }

    factory :guardian_with_user do
      sequence(:email){ |n| "guardian#{n}@mail.com" }
    end
  end

  factory :user do
    sequence(:email){ |n| "user#{n}@mail.com" }
  end

  factory :post do
    title "Some Post"
    association :author, factory: :teacher

    after(:build){ |post| post.initialize_tags if post.invalid? }
  end

  factory :tag do
    sequence(:name){ |n| "tag#{n}"}
  end

  factory :group do
    sequence(:name){ |n| "tag#{n}"}
  end

  factory :comment do
    post
    association :author, factory: :teacher
    content "Some content"
  end

  factory :student_observation do
    post
    student
    content "Some content"
  end

  factory :subject do
    sequence(:name){ |n| "subject#{n}"}
  end

  factory :strand do
    subject
    sequence(:name){ |n| "strand#{n}"}
  end

  factory :milestone do
    strand
    level 1
    sequence(:content){ |n| "milestone#{n}"}
  end
end