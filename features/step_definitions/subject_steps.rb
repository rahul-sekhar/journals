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
  page.should have_xpath('//ol[@class="strands"]/li', text: /^#{Regexp.escape(p_name)}/i, visible: true)
end

Then(/^I should not see the root strand "(.*?)"$/) do |p_name|
  page.should have_no_xpath('//ol[@class="strands"]/li', text: /^#{Regexp.escape(p_name)}/i, visible: true)
end

Then(/^I should see the strand "(.*?)" under "(.*?)"$/) do |p_child, p_parent|
  page.find('li', text: /^#{Regexp.escape(p_parent)}/i).should have_xpath('.//ol/li', text: /^#{Regexp.escape(p_child)}/i, visible: true)
end

Then(/^I should not see the strand "(.*?)" under "(.*?)"$/) do |p_child, p_parent|
  page.find('li', text: /^#{Regexp.escape(p_parent)}/i).should have_no_xpath('.//ol/li', text: /^#{Regexp.escape(p_child)}/i, visible: true)
end

Then(/^I should see the milestone "(.*?)" under "(.*?)" in level (\d+)$/) do |p_milestone, p_strand, p_level|
  strand = page.find('li', text: /^#{Regexp.escape(p_strand)}/i)
  strand.should have_xpath(".//tr/td[position()=#{p_level}]/ul/li", text: /^#{Regexp.escape(p_milestone)}/i, visible: true)
end

Then(/^I should not see the milestone "(.*?)" under "(.*?)" in level (\d+)$/) do |p_milestone, p_strand, p_level|
  strand = page.find('li', text: /^#{Regexp.escape(p_strand)}/i)
  strand.should have_no_xpath(".//tr/td[position()=#{p_level}]/ul/li", text: /^#{Regexp.escape(p_milestone)}/i, visible: true)
end

When(/^I change the strand "(.*?)" to "(.*?)"$/) do |p_from, p_to|
  field = page.find('ol.strands li p', text: /^#{Regexp.escape(p_from)}/i)
  field.find('.value').click
  fill_input_inside field, p_to
end

When(/^I delete the strand "(.*?)"$/) do |p_strand|
  strand = page.find('.strands li', text: /^#{Regexp.escape(p_strand)}/i, visible: true)
  strand.first('.title').click
  strand.first('.delete').click
end

When(/^I add the root strand "(.*?)"$/) do |p_strand|
  framework = page.find("#framework")
  framework.first('.add').click
  fill_input_inside framework, p_strand
end

When(/^I add the strand "(.*?)" to "(.*?)"$/) do |p_strand, p_parent|
  strand = page.find('li', text: /^#{Regexp.escape(p_parent)}/i)
  strand.first('.title').click
  strand.first('.add').click
  fill_input_inside strand, p_strand
end

When(/^I change the milestone "(.*?)" to "(.*?)"$/) do |p_from, p_to|
  field = page.find('table.milestones li p', text: /^#{Regexp.escape(p_from)}/i)
  field.find('.value').click
  fill_input_inside field, p_to
end

When(/^I delete the milestone "(.*?)"$/) do |p_milestone|
  milestone = page.find('table.milestones li', text: /^#{Regexp.escape(p_milestone)}/i, visible: true)
  milestone.click
  milestone.find('.delete').click
end

When(/^I add the milestone "(.*?)" to "(.*?)" in level (\d+)$/) do |p_milestone, p_strand, p_level|
  strand = page.find('li', text: /^#{Regexp.escape(p_strand)}/i)
  level = strand.find(:xpath, ".//tr[position()=2]/td[position()=#{p_level}]")
  level.click
  level.find('.add').click
  fill_input_inside level, p_milestone
end
