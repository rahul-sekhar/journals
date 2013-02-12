Given /^a teacher profile for Shalini exists$/ do
  @profile = FactoryGirl.create(:teacher, full_name: "Shalini Sekhar", email: "shalini@mail.com")
end

Given /^a teacher profile for Shalini with all information exists$/ do
  step 'a teacher profile for Shalini exists'

  @profile.update_attributes(
    mobile: '1122334455',
    address: "Some house,\nBanashankari,\nBangalore - 55",
    home_phone: '080-12345',
    office_phone: '080-67890',
    additional_emails: 'shalu@short.com, shalini_sekhar@long.com',
    notes: 'A test sister'
  )
end

Given /^a student profile for Parvathy exists$/ do
  @profile = FactoryGirl.create(:student, full_name: "Parvathy Manjunath", email: "parvathy@mail.com")
end

Given /^a student profile for Parvathy with all information exists$/ do
  step 'a student profile for Parvathy exists'

  @profile.update_attributes(
    mobile: '12345678',
    address: "Apartment,\nThe hill,\nDarjeeling - 10",
    home_phone: '5678',
    office_phone: '1432',
    formatted_birthday: '25-12-1996',
    blood_group: 'B+'
  )
end

Given /^a guardian Manoj for that student exists$/ do
  @guardian = @profile.guardians.create!(full_name: "Manoj Jain")
end

Given /^I have the guardian "(.*?)"$/ do |p_full_name|
  @guardian = @logged_in_user.profile.guardians.create!(full_name: p_full_name)
  
end

Given /^a guardian Poonam for that student exists$/ do
  @guardian = @profile.guardians.create!(
    full_name: "Poonam Jain", 
    email: "poonam@mail.com",
    mobile: "987654",
    address: "A house,\n\nSomewhere",
    home_phone: "111-222",
    office_phone: "333-444"
  )
end

Given /^a guardian Manoj with multiple students exists$/ do
  step 'a student profile for Parvathy exists'
  @profile = @profile.guardians.create!(full_name: "Manoj Jain")
  @student = FactoryGirl.create(:student, full_name: "Roly Jain", email: "roly@mail.com")
  @profile.students << @student
end

Given /^the profile has been activated$/ do
  @profile.user.generate_password
  @profile.save!
end

Given /^the profile has no email address$/ do
  @profile.email = nil
  @profile.save!
end

Given /^a (teacher|student) named "(.*?)" exists$/ do |p_type, p_full_name|
  @profile = FactoryGirl.create(p_type, full_name: p_full_name)
end

Given /^that teacher|student is archived$/ do
  @profile.toggle_archive
end

Given /^the profile in question is my students profile$/ do
  @profile = @student
end

When /^I click the "Edit profile" link for the guardian "(.*?)"$/ do |p_guardian_name|
  guardian_node = page.find(:xpath, '//h4[text()="' + p_guardian_name + '"]/../..')
  guardian_node.find('.edit-link').click
end
