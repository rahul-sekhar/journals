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

When(/^I edit the framework for the subject "(.*?)"$/) do |p_name|
  page.find('#subjects li', text: /^#{Regexp.escape(p_name)}/i, visible: true).find('.edit').click
end

Given(/^the subject "(.*?)" exists with a framework$/) do |p_name|
  @subject = Subject.create(name: p_name)
  strand1 = @subject.add_strand('Numbers')
  strand2 = strand1.add_strand('Counting')
  strand3 = strand2.add_strand('Child')
  strand4 = strand1.add_strand('Adding')
  strand5 = @subject.add_strand('Geometry')

  strand3.add_milestone(1, 'Some milestone')
  strand3.add_milestone(1, 'Another one')
  strand3.add_milestone(2, 'Third')

  strand4.add_milestone(2, 'Middle milestone')
end

Then(/^I should see the root strand "(.*?)"$/) do |p_name|
  page.should have_xpath('//ol[@class="strands"]/li', text: /^#{Regexp.escape(p_name)}/i)
end

Then(/^I should see the strand "(.*?)" under "(.*?)"$/) do |p_child, p_parent|
  page.find('li', text: /^#{Regexp.escape(p_parent)}/i).should have_xpath('.//ol/li', text: /^#{Regexp.escape(p_child)}/i)
end

Then(/^I should see the milestone "(.*?)" under "(.*?)" in level (\d+)$/) do |p_milestone, p_strand, p_level|
  page.find('li', text: /^#{Regexp.escape(p_strand)}/i).should have_xpath(".//tr/td[position()=#{p_level}]/ul/li", text: /^#{Regexp.escape(p_milestone)}/i)
end