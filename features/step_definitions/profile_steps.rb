Given /^a teacher profile for Shalini exists$/ do
  @profile = FactoryGirl.create(:teacher, first_name: "Shalini", last_name: "Sekhar", email: "shalini@mail.com")
end

Given /^a teacher profile for Shalini with all information exists$/ do
  step 'a teacher profile for Shalini exists'

  @profile.update_attributes(
    mobile: '1122334455',
    address: "Some house,\nBanashankari,\nBangalore - 55",
    home_phone: '080-12345',
    office_phone: '080-67890'
  )
end

Given /^a student profile for Parvathy exists$/ do
  @profile = FactoryGirl.create(:student, first_name: "Parvathy", last_name: "Manjunath", email: "parvathy@mail.com")
end

Given /^a student profile for Parvathy with all information exists$/ do
  step 'a student profile for Parvathy exists'

  @profile.update_attributes(
    mobile: '12345678',
    address: "Apartment,\nThe hill,\nDarjeeling - 10",
    home_phone: '5678',
    office_phone: '1432',
    formatted_birthday: '25-12-1996',
    bloodgroup: 'B+'
  )
end

Given /^a guardian Manoj for that student exists$/ do
  @guardian = @profile.guardians.create!(first_name: "Manoj", last_name: "Jain")
end

Given /^a guardian Poonam for that student exists$/ do
  @guardian = @profile.guardians.create!(
    first_name: "Poonam", 
    last_name: "Jain",
    email: "poonam@mail.com",
    mobile: "987654",
    address: "A house,\n\nSomewhere",
    home_phone: "111-222",
    office_phone: "333-444"
  )
end

Given /^a guardian Manoj with multiple students exists$/ do
  step 'a student profile for Parvathy exists'
  @profile = @profile.guardians.create!(first_name: "Manoj", last_name: "Jain")
  @student = FactoryGirl.create(:student, first_name: "Roly", last_name: "Jain", email: "roly@mail.com")
  @profile.students << @student
end

Given /^that profile has been activated$/ do
  @profile.user.generate_password
  @profile.save!
end
