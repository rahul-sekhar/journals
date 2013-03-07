# Given /^the groups "(.*?)" exist$/ do |p_groups|
#   Group.find_or_build_list(p_groups).each do |group|
#     group.save!
#   end
# end

# Given /^that student belongs to the groups "(.*?)"$/ do |p_groups|
#   @profile.groups = Group.find_or_build_list(p_groups)
#   @profile.save!
# end

# Given /^I belong to the groups "(.*?)"$/ do |p_groups|
#   profile = @logged_in_user.profile
#   profile.groups = Group.find_or_build_list(p_groups)
#   profile.save!
# end

# Given /^a group "(.*?)" exists$/ do |p_group|
#   @group = Group.create!(name: p_group)
# end

# Given /^that group has the students Roly, Lucky and Jumble$/ do
#   @group.students << FactoryGirl.create(:student, full_name: "Roly Sekhar")
#   @group.students << FactoryGirl.create(:student, full_name: "Lucky Sekhar")
#   @group.students << FactoryGirl.create(:student, full_name: "Jumble Sekhar")
# end

# When /^I open the manage groups dialog$/ do
#   step 'I click "add" in a "p" element'
#   step 'I click "Manage groups"'
# end