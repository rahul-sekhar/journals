Given /^a (teacher) "(.*?)" exists$/ do |p_type, p_name|
  first_name, last_name = split_name(p_name)
  email = mail_from_name(p_name)
  Teacher.create!(first_name: first_name, last_name: last_name, email: email, password: "pass")
end

Given /^a (teacher) "(.*?)" exists with the email "(.*?)" and the password "(.*?)"$/ do |p_type, p_name, p_email, p_pass|
  first_name, last_name = split_name(p_name)
  Teacher.create!(first_name: first_name, last_name: last_name, email: p_email, password: p_pass)
end

Given /^I have logged in as a (teacher) "(.*?)"$/ do |p_type, p_name|
  email = mail_from_name(p_name)
  step "a #{p_type} \"#{p_name}\" exists with the email \"#{email}\" and the password \"pass\""
  step 'I am on the login page'
  step "I fill in \"Email\" with \"#{email}\""
  step 'I fill in "Password" with "pass"'
  step 'I click "Log in"'
end

def split_name(full_name)
  words_in_name = full_name.split(" ")
  last_name = words_in_name.pop
  first_name = words_in_name.join(" ")
  return [first_name, last_name]
end

def mail_from_name(p_name)
  "#{p_name.downcase.gsub(' ', '.')}@mail.com"
end