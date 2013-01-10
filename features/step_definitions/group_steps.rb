Given /^the groups "(.*?)" exist$/ do |p_groups|
  Group.find_or_build_list(p_groups).each do |group|
    group.save!
  end
end

Given /^that student belongs to the groups "(.*?)"$/ do |p_groups|
  @profile.groups = Group.find_or_build_list(p_groups)
  @profile.save!
end

Given /^I belong to the groups "(.*?)"$/ do |p_groups|
  profile = @logged_in_user.profile
  profile.groups = Group.find_or_build_list(p_groups)
  profile.save!
end

Given /^a group "(.*?)" exists$/ do |p_group|
  @group = Group.create!(name: p_group)
end

Given /^that group has the students Roly, Lucky and Jumble$/ do
  @group.students << FactoryGirl.create(:student, first_name: "Roly", last_name: "Sekhar")
  @group.students << FactoryGirl.create(:student, first_name: "Lucky", last_name: "Sekhar")
  @group.students << FactoryGirl.create(:student, first_name: "Jumble", last_name: "Sekhar")
end