Given /^a teacher Shalini exists$/ do
  step 'a teacher "Shalini Sekhar" exists'
  @profile.update_attributes(
    mobile: '1122334455',
    address: "Some house,\nBanashankari,\nBangalore - 55",
    home_phone: '080-12345',
    office_phone: '080-67890',
    additional_emails: 'shalu@short.com, shalini_sekhar@long.com',
    notes: 'A test sister'
  )
end

Given /^a student Parvathy exists$/ do
  step 'a student "Parvathy Manjunath" exists'
  @profile.update_attributes(
    mobile: '12345678',
    address: "Apartment,\nThe hill,\nDarjeeling - 10",
    home_phone: '5678',
    office_phone: '1432',
    birthday: '25-12-1996',
    blood_group: 'B+'
  )
end

Given /^a guardian Poonam exists for that student$/ do
  @guardian = @profile.guardians.create!(
    name: "Poonam Jain",
    email: "poonam@mail.com",
    mobile: "987654",
    address: "A house,\n\nSomewhere",
    home_phone: "111-222",
    office_phone: "333-444"
  )
end

Given /^a guardian Manoj with multiple students exists$/ do
  step 'a student "Parvathy Manjunath" exists'
  @profile = @profile.guardians.create!(name: "Manoj Jain")
  @student = FactoryGirl.create(:student, name: "Roly Jain", email: "roly@mail.com")
  @profile.students << @student
end

Given /^a teacher for each alphabet exists$/ do
  ('A'..'Z').each do |letter|
    Teacher.create!(name: letter)
  end
end

Given /^a student for each alphabet exists$/ do
  ('A'..'Z').each do |letter|
    Student.create!(name: letter)
  end
end

Given /^an archived student for each alphabet exists$/ do
  ('A'..'Z').each do |letter|
    student = Student.create!(name: letter)
    student.toggle_archive
  end
end