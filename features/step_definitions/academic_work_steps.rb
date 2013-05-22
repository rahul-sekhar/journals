Given(/^the student John has done some work on Maths$/) do
  step 'the subject "Maths" exists with a framework'
  student = create_profile('student', 'John Doe')

  FactoryGirl.create(:unit, student: student, subject: @subject, name: "Unit 1", started: Date.new(2011, 5, 5))
  FactoryGirl.create(:unit, student: student, subject: @subject, name: "Unit 2",
    started: Date.new(2010, 1, 10),
    due: Date.new(2010, 5, 10),
    completed: Date.new(2010, 5, 6),
    comments: "Well done!"
    )
  FactoryGirl.create(:unit, name: "Unwanted Unit")
  FactoryGirl.create(:unit, name: "Unwanted Unit", subject: @subject)
  FactoryGirl.create(:unit, name: "Unwanted Unit", student: student)
end
