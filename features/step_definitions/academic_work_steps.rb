Given(/^the student John has done some work on Maths$/) do
  step 'the subject "Maths" exists'
  student = create_profile('student', 'John Doe')

  st = @subject.add_teacher(@profile)
  st.students << student

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

Given(/^the student John has some milestones set for Maths$/) do
  step 'the subject "Maths" exists with a framework'
  student = create_profile('student', 'John Doe')

  FactoryGirl.create(:student_milestone,
    student: student,
    milestone: Milestone.where(content: 'Some milestone').first,
    status: 2,
    comments: 'Blah blah'
  )

  FactoryGirl.create(:student_milestone,
    student: student,
    milestone: Milestone.where(content: 'Third').first,
    status: 3
  )

  FactoryGirl.create(:student_milestone,
    student: student,
    milestone: Milestone.where(content: 'Middle milestone').first,
    status: 0,
    comments: 'Some comment',
    updated_at: Date.new(2012, 10, 1)
  )
end

Given(/^John has a few more subjects$/) do
  student = Student.where(first_name: "John").first
  Subject.create!(name: "History")
  subject = Subject.create!(name: "English")

  st = subject.add_teacher(@profile)
  st.students << student
end

Then(/^I should see "(.*?)" in row (\d+) of the milestones table$/) do |p_content, p_row|
  page.all('#milestones tr', visible: true)[p_row.to_i].should have_content p_content
end

Then(/^the milestone "(.*?)" should have the status (\d+)$/) do |p_milestone, p_status|
  page.find('li', text: /^#{p_milestone}/i).
    find('.student-milestone').
    should have_css(".status-#{p_status}")
end

Then(/^the milestone "(.*?)" should have the comment "(.*?)"$/) do |p_milestone, p_text|
  page.find('li', text: /^#{p_milestone}/i).
    find('.student-milestone').
    should have_content p_text
end

Then(/^the milestone "(.*?)" should have no comment$/) do |p_milestone|
  page.find('li', text: /^#{p_milestone}/i).
    find('.student-milestone').text.should eq('')
end

When(/^I set the milestone "(.*?)" to status (\d+) with the comment "(.*?)"$/) do |p_milestone, p_status, p_comment|
  page.find('li', text: /^#{p_milestone}/i).click
  dialog = page.find('#modify-student-milestone', visible: true)
  within dialog do
    page.find(".status-#{p_status}").click
    page.find('textarea').set(p_comment)
    page.find('.submit').click
  end
end
