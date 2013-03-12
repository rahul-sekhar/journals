Given /^I have the mentees "(.*?)"$/ do |p_students|
  profile = @logged_in_profile
  profile.mentees = p_students.split(", ").map{ |student| Student.find_by_first_name!(student) }
  profile.save!
end

Given /^all the students are my mentees$/ do
  profile = @logged_in_profile
  profile.mentees = Student.all
  profile.save!
end

Then /^I should see "(.*?)" in its mentors$/ do |p_content|
  @viewing.find('.mentors .existing').should have_content p_content
end

Then /^I should not see "(.*?)" in its mentors$/ do |p_content|
  @viewing.find('.mentors .existing').should have_no_content p_content
end

When /^I remove the mentor "(.*?)" from it$/ do |p_mentor|
  @viewing.find('.mentors .existing span', text: /^#{Regexp.escape(p_mentor)}$/i, visible: true).first(:xpath, './/..').find('.remove').click
end

# Given /^the teachers Angela, Shalini, Aditya and Sharad exist$/ do
#   FactoryGirl.create(:teacher, full_name: "Angela Jain")
#   FactoryGirl.create(:teacher, full_name: "Shalini Sekhar")
#   FactoryGirl.create(:teacher, full_name: "Aditya Pandya")
#   FactoryGirl.create(:teacher, full_name: "Sharad Jain")
# end

# Given /^that student belongs to the mentors "(.*?)"$/ do |p_teachers|
#   @profile.mentors = p_teachers.split(", ").map{ |teacher| Teacher.find_by_first_name!(teacher) }
#   @profile.save!
# end

# Given /^I belong to the mentors "(.*?)"$/ do |p_teachers|
#   profile = @logged_in_user.profile
#   profile.mentors = p_teachers.split(", ").map{ |teacher| Teacher.find_by_first_name!(teacher) }
#   profile.save!
# end

# Given /^the students Roly, Lucky and Jumble exist$/ do
#   FactoryGirl.create(:student, full_name: "Roly Sekhar")
#   FactoryGirl.create(:student, full_name: "Lucky Sekhar")
#   FactoryGirl.create(:student, full_name: "Jumble Sekhar")
# end

# Given /^that profile has the mentees "(.*?)"$/ do |p_students|
#   @profile.mentees = p_students.split(", ").map{ |student| Student.find_by_first_name!(student) }
#   @profile.save!
# end
