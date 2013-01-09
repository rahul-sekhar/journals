Given /^the groups "(.*?)" exist$/ do |p_groups|
  Group.find_or_build_list(p_groups).each do |group|
    group.save!
  end
end

Given /^that student belongs to the groups "(.*?)"$/ do |p_groups|
  @profile.groups = Group.find_or_build_list(p_groups)
  @profile.save!
end
