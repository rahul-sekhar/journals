# Set up profiles
Given /^a (teacher|student) Rahul exists$/ do |p_type|
  @profile = create_profile(p_type, 'Rahul Sekhar', 'rahul@mail.com')
  set_profile_password(@profile, 'pass')
end

Given /^a guardian Rahul exists$/ do
  student = create_profile('student', 'Roly Sekhar')
  student.guardians.create!(full_name: 'Shalini Sekhar', email: 'shalini@mail.com')
  @profile = student.guardians.create!(full_name: 'Rahul Sekhar', email: 'rahul@mail.com')
  set_profile_password(@profile, 'pass')
end

Given /^an?( archived)? (teacher|student) "(.*?)" exists$/ do |p_archived, p_type, p_name|
  @profile = create_profile(p_type, p_name)
  @profile.toggle_archive if p_archived.present?
end

Given /^a guardian "(.*?)" exists for that student$/ do |p_name|
  @guardian = @profile.guardians.create!(full_name: p_name)
end

Given /^I have the guardian "(.*?)"$/ do |p_name|
  @logged_in_profile.guardians.create!(full_name: p_name, email: mail_from_name(p_name))
end

Given /^the profile has been activated$/ do
  @profile.user.generate_password
  @profile.save!
end

Given /^the profile has no email address$/ do
  @profile.email = nil
  @profile.save!
end

Given /^the guardian has no email address$/ do
  @guardian.email = nil
  @guardian.save!
end

Given /^the teachers (.*) exist$/ do |p_teachers|
  p_teachers.split(',').each do |name|
    create_profile('Teacher', name)
  end
end

Given /^the students (.*) exist$/ do |p_students|
  p_students.split(',').each do |name|
    create_profile('Student', name)
  end
end


# Test profiles
Then /^I should see a profile for "(.*?)"$/ do |p_name|
  page.should have_css(".profile h3", text: /#{Regexp.escape(p_name)}/, visible: true)
end

Then /^I should not see a profile for "(.*?)"$/ do |p_name|
  page.should have_no_css(".profile h3", text: /#{Regexp.escape(p_name)}/, visible: true)
end

When /^I look at the profile for "(.*?)"$/ do |p_name|
  @viewing = page.find(".profile header", text: /#{Regexp.escape(p_name)}/, visible: true).
    first(:xpath, ".//..")
end

When /^I look at the guardian "(.*?)"$/ do |p_guardian|
  @viewing = @viewing.find(".guardian", text: /#{Regexp.escape(p_guardian)}/, visible: true)
end

Then /^I should see the guardian "(.*?)"$/ do |p_guardian|
  @viewing.should have_css(".guardian", text: /#{Regexp.escape(p_guardian)}/, visible: true)
end

Then /^I should not see the guardian "(.*?)"$/ do |p_guardian|
  @viewing.should have_no_css(".guardian", text: /#{Regexp.escape(p_guardian)}/, visible: true)
end


# Adding
When /^I add the (teacher|student) "(.*?)"$/ do |p_type, p_name|
  step 'I select "Add ' + p_type + '" from the add menu'
  @viewing = page.first('.profile')
  fill_input_inside @viewing.find('h3'), p_name
end

When /^I add the guardian "(.*?)"$/ do |p_name|
  within @viewing do
    click_on "Add guardian"
    guardian = page.first('.guardians')
    fill_input_inside guardian.find('h4'), p_name
  end
end


# Fields
Then /^I should see the field "(.*?)" with "(.*?)"$/ do |p_field, p_content|
  within @viewing do
    field = page.find('.field-name', text: /^#{Regexp.escape(p_field)}$/i, visible: true)
    parent = field.first(:xpath, ".//..")
    parent.should have_css('.value', text: /#{Regexp.escape(p_content)}/, visible: true)
  end
end

Then /^I should not see the field "(.*?)"$/ do |p_field|
  within @viewing do
    page.should have_no_css('.field-name', text: /^#{Regexp.escape(p_field)}$/i, visible: true)
  end
end

def field_from_text(text)
  if text == 'name'
    return page.find('h3')
  elsif text == 'guardian name'
    return page.find('h4')
  else
    text = text[7..-2]
    return page.find('.field-name', text: /^#{Regexp.escape(text)}$/i).first(:xpath, ".//..")
  end
end

When /^I change the (field ".*"|name|guardian name) to "(.*?)"$/ do |p_field, p_value|
  within @viewing do
    field = field_from_text(p_field)
    field.find('.value').click
    fill_input_inside field, p_value
  end
end

Then /^I should be able to change the (field ".*"|name|guardian name)$/ do |p_field|
  within @viewing do
    field = field_from_text(p_field)
    field.find('.value').click
    page.should have_css('input, textarea', visible: true)
    blur_input_inside field
  end
end

Then /^I should not be able to change the (field ".*"|name|guardian name)$/ do |p_field|
  within @viewing do
    field = field_from_text(p_field)
    field.find('.value').click
    page.should have_no_css('input, textarea', visible: true)
  end
end

Then /^I should be able to change the first field "(.*?)"$/ do |p_field|
  within @viewing do
    field = page.first('.field-name', text: /^#{Regexp.escape(p_field)}$/i).first(:xpath, ".//..")
    field.find('.value').click
    page.should have_css('input, textarea', visible: true)
    blur_input_inside field
  end
end

Then /^I should not be able to change the first field "(.*?)"$/ do |p_field|
  within @viewing do
    field = page.first('.field-name', text: /^#{Regexp.escape(p_field)}$/i).first(:xpath, ".//..")
    field.find('.value').click
    page.should have_no_css('input, textarea', visible: true)
  end
end

When /^I change the date field "(.*?)" to "(.*?)"$/ do |p_field, p_date|
  within @viewing do
    field = page.find('.field-name', text: /^#{Regexp.escape(p_field)}$/i).first(:xpath, ".//..")
    field.find('.value').click
    script = "setTimeout(function() {" +
      "$('input:not([name]):visible').datepicker('setDate', '#{p_date}').datepicker('hide');" +
    "}, 10);"
    page.execute_script(script)
  end
end

When /^I clear the (field ".*"|name|guardian name)$/ do |p_field|
  within @viewing do
    step 'I change the ' + p_field + ' to ""'
  end
end

When /^I clear the date field "(.*?)"$/ do |p_field|
  within @viewing do
    field = page.find('.field-name', text: /^#{Regexp.escape(p_field)}$/i).first(:xpath, ".//..")
    field.find('.value').click
    field.find('.clear-date').click
  end
end

When /^I add the field "(.*?)" with "(.*?)"$/ do |p_field, p_value|
  within @viewing do
    step 'I select "' + p_field + '" from the add-field menu'
    field = page.find('.field-name', text: /^#{Regexp.escape(p_field)}$/i).first(:xpath, ".//..")
    fill_input_inside field, p_value
  end
end

When /^I add the date field "(.*?)" with "(.*?)"$/ do |p_field, p_date|
  within @viewing do
    step 'I select "' + p_field + '" from the add-field menu'
    field = page.find('.field-name', text: /^#{Regexp.escape(p_field)}$/i).first(:xpath, ".//..")
    script = "setTimeout(function() {" +
      "$('input:not([name]):visible').datepicker('setDate', '#{p_date}').datepicker('hide');" +
    "}, 10);"
    page.execute_script(script)
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