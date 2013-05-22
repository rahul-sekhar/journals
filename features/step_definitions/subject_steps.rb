Given(/^the subject "(.*)" exists$/) do |p_name|
  @subject = Subject.create(name: p_name)
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

  @subject.add_teacher(teacher1)
  @subject.add_teacher(teacher2)
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