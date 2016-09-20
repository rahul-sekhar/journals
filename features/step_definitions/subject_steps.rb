Given(/^the subject "(.*)" exists$/) do |p_name|
  @subject = Subject.find_by_name(p_name)
  @subject = Subject.create!(name: p_name) unless @subject.present?
end

Then(/^I should see the subject "(.*)"$/) do |p_name|
  page.should have_css('#subjects li', text: /^#{Regexp.escape(p_name)}/i, visible: true)
end

Then(/^I should not see the subject "(.*)"$/) do |p_name|
  page.should have_no_css('#subjects li', text: /^#{Regexp.escape(p_name)}/i, visible: true)
end

When(/^I delete the subject "(.*?)"$/) do |p_name|
  page.find('#subjects li', text: /^#{Regexp.escape(p_name)}/i, visible: true).find('.delete').click
end

When(/^I change the subject "(.*?)" to "(.*?)"$/) do |p_from, p_to|
  field = page.find('#subjects li', text: /^#{Regexp.escape(p_from)}/i)
  field.find('.value').click
  fill_input_inside field, p_to
end

When /^I add the subject "(.*?)"$/ do |p_name|
  subjects = page.find('#subjects')
  subjects.find('.add').click
  fill_input_inside subjects, p_name
end

Given(/^the subject "(.*?)" exists with teachers and students$/) do |p_name|
  @subject = Subject.create(name: p_name)
  teacher1 = create_profile('teacher', 'John Doe')
  teacher2 = create_profile('teacher', 'William Tell')
  create_profile('teacher', 'Bruce Lee')

  st1 = @subject.add_teacher(teacher1)
  st2 = @subject.add_teacher(teacher2)

  student1 = create_profile('student', 'Jimmy Fallon')
  student2 = create_profile('student', 'Stephen Colbert')
  create_profile('student', 'Craig Ferguson')

  st1.students << [student1, student2]
  st2.students << student2
end

Given(/^the subject "(.*?)" has the column name "(.*?)"$/) do |p_subject, p_column_name|
  Subject.find_by_name!(p_subject).update_attributes!(column_name: p_column_name)
end

Given(/^the subject "(.*?)" has no level numbers$/) do |p_subject|
  Subject.find_by_name!(p_subject).update_attributes!(level_numbers: false)
end

When(/^I manage people for the subject "(.*?)"$/) do |p_name|
  page.find('#subjects li', text: /^#{Regexp.escape(p_name)}/i, visible: true).find('.people').click
end

Then(/^I should see "(.*?)" in its teachers$/) do |p_teacher|
  @viewing.find('.teachers').should have_content p_teacher
end

Then(/^I should not see "(.*?)" in its teachers$/) do |p_teacher|
  @viewing.find('.teachers').should have_no_content p_teacher
end

When(/^I remove the teacher "(.*?)" from it$/) do |p_teacher|
  @viewing.find('.teachers li', text: /^#{Regexp.escape(p_teacher)}/i, visible: true).find('.delete').click
end

When(/^I select the teacher "(.*?)"$/) do |p_teacher|
  @viewing.find('.teachers li', text: /^#{Regexp.escape(p_teacher)}/i, visible: true).find('p').click
end

Then(/^I should see "(.*?)" in its students$/) do |p_student|
  @viewing.find('.students').should have_content p_student
end

Then(/^I should not see "(.*?)" in its students$/) do |p_student|
  @viewing.find('.students').should have_no_content p_student
end

When(/^I remove the student "(.*?)" from it$/) do |p_teacher|
  @viewing.find('.students li', text: /^#{Regexp.escape(p_teacher)}/i, visible: true).find('.delete').click
end