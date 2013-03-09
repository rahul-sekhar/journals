When /^I log in with "(.*?)" and "(.*?)"$/ do |p_email, p_pass|
  fill_in 'Email', with: p_email
  fill_in 'Password', with: p_pass
  click_on 'Log in'
end

Given /^I have logged in as the (teacher|student|guardian) Rahul$/ do |p_type|
  step 'a ' + p_type + ' Rahul exists'
  @logged_in_profile = @profile
  step 'I am on the login page'
  step 'I log in with "rahul@mail.com" and "pass"'
end
