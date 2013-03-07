# Set up profiles
Given /^a (teacher|student) Rahul exists$/ do |p_type|
  @profile = create_profile(p_type, 'Rahul Sekhar', 'rahul@mail.com')
  set_profile_password(@profile, 'pass')
end

Given /^an?( archived)? (teacher|student) "(.*?)" exists$/ do |p_archived, p_type, p_name|
  @profile = create_profile(p_type, p_name)
  @profile.toggle_archive if p_archived.present?
end

Given /^a guardian "(.*?)" exists for that student$/ do |p_name|
  @guardian = @profile.guardians.create!(full_name: p_name)
end

# Specific profiles
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
    formatted_birthday: '25-12-1996',
    blood_group: 'B+'
  )
end

Given /^a guardian Poonam exists for that student$/ do
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
  step 'a student "Parvathy Manjunath" exists'
  @profile = @profile.guardians.create!(full_name: "Manoj Jain")
  @student = FactoryGirl.create(:student, full_name: "Roly Jain", email: "roly@mail.com")
  @profile.students << @student
end


# Test profiles
Then /^I should see a profile for "(.*?)"$/ do |p_name|
  page.should have_css(".profile h3", text: /#{p_name}/, visible: true)
end

Then /^I should not see a profile for "(.*?)"$/ do |p_name|
  page.should have_no_css(".profile h3", text: /#{p_name}/, visible: true)
end

When /^looking at the profile for "(.*?)"$/ do |p_name|
  @viewing = page.find(".profile", text: /#{p_name}/, visible: true)
end

When /^looking at the guardian "(.*?)"$/ do |p_guardian|
  @viewing = @viewing.find(".guardian", text: /#{p_guardian}/, visible: true)
end

Then /^I should see the guardian "(.*?)"$/ do |p_guardian|
  @viewing.should have_css(".guardian", text: /#{p_guardian}/, visible: true)
end

Then /^I should see the field "(.*?)" with "(.*?)"$/ do |p_field, p_content|
  within @viewing do
    field = page.find('.field-name', text: /^#{p_field}$/i, visible: true)
    parent = field.first(:xpath,".//..")
    parent.should have_content(p_content)
  end
end

Then /^I should not see the field "(.*?)"$/ do |p_field|
  within @viewing do
    page.should have_no_css('.field-name', text: /^#{p_field}$/i, visible: true)
  end
end



# Internal functions

def set_profile_password(profile, password)
  user = profile.user
  user.set_password password
end

def create_profile(type, name, email=nil)
  email ||= mail_from_name(name)
  klass = type.capitalize.constantize

  obj = klass.create!(full_name: name, email: email)
  return obj
end

def mail_from_name(p_name)
  "#{p_name.downcase.gsub(' ', '.')}@mail.com"
end



# Given /^I have the guardian "(.*?)"$/ do |p_full_name|
#   @guardian = @logged_in_user.profile.guardians.create!(full_name: p_full_name)
# end

# Given /^the profile has been activated$/ do
#   @profile.user.generate_password
#   @profile.save!
# end

# Given /^the profile has no email address$/ do
#   @profile.email = nil
#   @profile.save!
# end

# Given /^a (teacher|student) named "(.*?)" exists$/ do |p_type, p_full_name|
#   @profile = FactoryGirl.create(p_type, full_name: p_full_name)
# end

# Given /^the profile in question is my students profile$/ do
#   @profile = @student
# end

# When /^I click the "Edit profile" link for the guardian "(.*?)"$/ do |p_guardian_name|
#   guardian_node = page.find(:xpath, '//h4[text()="' + p_guardian_name + '"]/../..')
#   guardian_node.find('.edit-link').click
# end

# Given /^a teacher for each alphabet exists$/ do
#   ('A'..'Z').each do |letter|
#     Teacher.create!(full_name: letter)
#   end
# end

# Given /^a student for each alphabet exists$/ do
#   ('A'..'Z').each do |letter|
#     Student.create!(full_name: letter)
#   end
# end

# Given /^an archived student for each alphabet exists$/ do
#   ('A'..'Z').each do |letter|
#     student = Student.create!(full_name: letter)
#     student.toggle_archive
#   end
# end
