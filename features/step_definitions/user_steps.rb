Given /^a (teacher) profile "(.*?)" with the password "(.*?)" exists$/ do |p_type, p_name, p_pass|
  first_name, last_name = split_name(p_name)
  TeacherProfile.create(first_name: first_name, last_name: last_name, password: p_pass)
end

Given /^I have logged in as a (teacher), "(.*?)"$/ do |p_type, p_name|
  step "a #{p_type} profile \"#{p_name}\" with the password \"pass\" exists"
  step 'I am on the login page'
  step 'I fill in "Username" with "rahul"'
  step 'I fill in "Password" with "pass"'
  step 'I click "Log in"'
end

def split_name(full_name)
  words_in_name = full_name.split(" ")
  last_name = words_in_name.pop
  first_name = words_in_name.join(" ")
  return [first_name, last_name]
end