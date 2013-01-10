Given /^the teachers Angela, Shalini, Aditya and Sharad exist$/ do
  FactoryGirl.create(:teacher, first_name: "Angela", last_name: "Jain")
  FactoryGirl.create(:teacher, first_name: "Shalini", last_name: "Sekhar")
  FactoryGirl.create(:teacher, first_name: "Aditya", last_name: "Pandya")
  FactoryGirl.create(:teacher, first_name: "Sharad", last_name: "Jain")
end

Given /^that student belongs to the mentors "(.*?)"$/ do |p_teachers|
  @profile.mentors = p_teachers.split(", ").map{ |teacher| Teacher.find_by_first_name!(teacher) }
  @profile.save!
end

Given /^I belong to the mentors "(.*?)"$/ do |p_teachers|
  profile = @logged_in_user.profile
  profile.mentors = p_teachers.split(", ").map{ |teacher| Teacher.find_by_first_name!(teacher) }
  profile.save!
end

Given /^the students Roly, Lucky and Jumble exist$/ do
  FactoryGirl.create(:student, first_name: "Roly", last_name: "Sekhar")
  FactoryGirl.create(:student, first_name: "Lucky", last_name: "Sekhar")
  FactoryGirl.create(:student, first_name: "Jumble", last_name: "Sekhar")
end

Given /^I have the mentees "(.*?)"$/ do |p_students|
  profile = @logged_in_user.profile
  profile.mentees = p_students.split(", ").map{ |student| Student.find_by_first_name!(student) }
  profile.save!
end

Given /^that profile has the mentees "(.*?)"$/ do |p_students|
  @profile.mentees = p_students.split(", ").map{ |student| Student.find_by_first_name!(student) }
  @profile.save!
end
