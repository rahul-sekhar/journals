Given /^the groups "(.*?)" exist$/ do |p_groups|
  Group.find_or_build_list(p_groups).each do |group|
    group.save!
  end
end

Given /^a group "(.*?)" exists$/ do |p_group|
  @group = Group.create!(name: p_group)
end

Given /^that student belongs to the groups "(.*?)"$/ do |p_groups|
  @profile.groups = Group.find_or_build_list(p_groups)
  @profile.save!
end

Given /^all the students have a group "(.*?)"$/ do |p_group|
  @group = Group.create!(name: p_group)
  @group.students = Student.all
end


# Given /^I belong to the groups "(.*?)"$/ do |p_groups|
#   profile = @logged_in_user.profile
#   profile.groups = Group.find_or_build_list(p_groups)
#   profile.save!
# end


# Given /^that group has the students Roly, Lucky and Jumble$/ do
#   @group.students << FactoryGirl.create(:student, full_name: "Roly Sekhar")
#   @group.students << FactoryGirl.create(:student, full_name: "Lucky Sekhar")
#   @group.students << FactoryGirl.create(:student, full_name: "Jumble Sekhar")
# end

When /^I delete the group "(.*?)"$/ do |p_group|
  page.find('#groups li', text: /^#{p_group}/i, visible: true).find('.delete').click
end

When /^I change the group "(.*?)" to "(.*?)"$/ do |p_from, p_to|
  field = page.find('#groups li', text: /^#{Regexp.escape(p_from)}/i)
  field.find('.value').click
  fill_input_inside field, p_to
end

When /^I add the group "(.*?)"$/ do |p_group|
  groups = page.find('#groups')
  groups.find('.add').click
  fill_input_inside groups, p_group
end

# Profile groups
Then /^I should see "(.*?)" in its groups$/ do |p_content|
  @viewing.find('.groups .existing').should have_content p_content
end

Then /^I should not see "(.*?)" in its groups$/ do |p_content|
  @viewing.find('.groups .existing').should have_no_content p_content
end

When /^I remove the group "(.*?)" from it$/ do |p_group|
  @viewing.find('.groups .existing span', text: /^#{Regexp.escape(p_group)}$/i, visible: true).first(:xpath, './/..').find('.remove').click
end


