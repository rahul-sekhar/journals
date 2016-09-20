def create_student_john(subject)
  @student = create_profile('student', 'John Doe')

  st = subject.add_teacher(@profile)
  st.students << @student
end

def add_subject_for_self(subject)
  @student = @profile
  st = subject.add_teacher(FactoryGirl.create(:teacher))
  st.students << @student
end

def add_subject_for_roly(subject)
  @student = Student.where(first_name: "Roly").first
  st = subject.add_teacher(FactoryGirl.create(:teacher))
  st.students << @student
end

Given(/^(the student John has|I have|my student Roly has) the subject "(.*?)"$/) do |p_protagonist, p_subject|
  @subject = Subject.find_by_name!(p_subject)

  if (p_protagonist == 'I have')
    add_subject_for_self(@subject)
  elsif (p_protagonist == 'my student Roly has')
    add_subject_for_roly(@subject)
  else
    create_student_john(@subject)
  end
end

Given(/^(the student John has|I have|my student Roly has) done some work on Maths$/) do |p_protagonist|
  step 'the subject "Maths" exists'

  if (p_protagonist == 'I have')
    add_subject_for_self(@subject)
  elsif (p_protagonist == 'my student Roly has')
    add_subject_for_roly(@subject)
  else
    create_student_john(@subject)
  end

  FactoryGirl.create(:unit, student: @student, subject: @subject, name: "Unit 1", started: Date.new(2011, 5, 5))
  FactoryGirl.create(:unit, student: @student, subject: @subject, name: "Unit 2",
    started: Date.new(2010, 1, 10),
    due: Date.new(2010, 5, 10),
    completed: Date.new(2010, 5, 6),
    comments: "Well done!"
    )
  FactoryGirl.create(:unit, name: "Unwanted Unit")
  FactoryGirl.create(:unit, name: "Unwanted Unit", subject: @subject)
  FactoryGirl.create(:unit, name: "Unwanted Unit", student: @student)
end

Given(/^(the student John has|I have|my student Roly has) some milestones set for Maths$/) do |p_protagonist|
  step 'the subject "Maths" exists with a framework'

  if (p_protagonist == 'I have')
    add_subject_for_self(@subject)
  elsif (p_protagonist == 'my student Roly has')
    add_subject_for_roly(@subject)
  else
    create_student_john(@subject)
  end

  FactoryGirl.create(:student_milestone,
    student: @student,
    milestone: Milestone.where(content: 'Some milestone').first,
    status: 2,
    comments: 'Blah blah'
  )

  FactoryGirl.create(:student_milestone,
    student: @student,
    milestone: Milestone.where(content: 'Third').first,
    status: 3
  )

  FactoryGirl.create(:student_milestone,
    student: @student,
    milestone: Milestone.where(content: 'Middle milestone').first,
    status: 0,
    comments: 'Some comment',
    date: '01-10-2012'
  )
end

Given(/^(?:John has|I have|my student Roly has) a few more subjects$/) do
  Subject.create!(name: "History")
  subject = Subject.create!(name: "English")

  st = subject.add_teacher(FactoryGirl.create(:teacher))
  st.students << @student
end

Then(/^I should see "(.*?)" in row (\d+) of the milestones table$/) do |p_content, p_row|
  page.all('#milestones tr', visible: true)[p_row.to_i].should have_content p_content
end

Then(/^the milestone "(.*?)" should have the status (\d+)$/) do |p_milestone, p_status|
  page.find('li', text: /^#{p_milestone}/i).
    find('.student-milestone').
    should have_css(".status-#{p_status}")
end

Then(/^the milestone "(.*?)" should have no status$/) do |p_milestone|
  page.find('li', text: /^#{p_milestone}/i).
    find('.student-milestone').
    should have_css(".status-0", visible: false)
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

Then(/^the milestone "(.*?)" should have the date "(.*?)"$/) do |p_milestone, p_text|
  page.find('li', text: /^#{p_milestone}/i).
    find('.student-milestone').
    should have_css '.date', text: p_text
end

Then(/^the milestone "(.*?)" should have no date$/) do |p_milestone|
  page.find('li', text: /^#{p_milestone}/i).
    should have_no_css '.student-milestone .date'
end

When(/^I set the milestone "(.*?)" to status (\d+) with the comment "([^"]*?)"$/) do |p_milestone, p_status, p_comment|
  page.find('li', text: /^#{p_milestone}/i).click
  dialog = page.find('#modify-student-milestone', visible: true)
  within dialog do
    page.find(".status-#{p_status}").click
    page.find('textarea').set(p_comment)
    page.find('.submit').click
  end
end

Then(/^I should not be able to set the milestone "(.*?)"$/) do |p_milestone|
  page.find('li', text: /^#{p_milestone}/i).click
  page.should have_no_css('#modify-student-milestone', visible: true)
end

When(/^I set the milestone "(.*?)" to status (\d+) with the comment "(.*?)" and the date "(.*?)"$/) do |p_milestone, p_status, p_comment, p_date|
  page.find('li', text: /^#{p_milestone}/i).click
  dialog = page.find('#modify-student-milestone', visible: true)
  within dialog do
    page.find(".status-#{p_status}").click
    page.find('textarea').set(p_comment)
    page.find(".date-field input").click
    script = "$('.date-field input:not([name]):visible').datepicker('setDate', '#{p_date}').datepicker('hide');"
    page.execute_script(script)
    page.find('.submit').click
  end
end