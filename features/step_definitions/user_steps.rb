Given /^a (teacher|student) "(.*?)" exists with the email "(.*?)" and the password "(.*?)"$/ do |p_type, p_name, p_email, p_pass|
  @profile = create_profile(p_type, p_name, p_email)
  set_profile_password(@profile, p_pass)
end

Given /^the guardian "(.*?)" has a student "(.*?)"$/ do |p_name, p_student_name|
  first_name, last_name = split_name(p_name)
  guardian = Guardian.find_by_name(first_name, last_name)

  guardian.students << create_profile("student", p_student_name)
end

Given /^I have logged in as a (teacher|student) "(.*?)"$/ do |p_type, p_name|
  email = mail_from_name(p_name)
  step "a #{p_type} \"#{p_name}\" exists with the email \"#{email}\" and the password \"pass\""
  step 'I am on the login page'
  step "I fill in \"Email\" with \"#{email}\""
  step 'I fill in "Password" with "pass"'
  step 'I click "Log in"'
  
  @logged_in_user = @profile.user
end

Given /^I have logged in as a guardian "(.*?)" to the student "(.*?)"$/ do |p_name, p_student_name|
  student = create_profile("student", p_student_name)
  first_name, last_name = split_name(p_name)
  email = mail_from_name(p_name)
  @profile = student.guardians.create!(first_name: first_name, last_name: last_name, email: email)
  set_profile_password(@profile, "pass")
  step 'I am on the login page'
  step "I fill in \"Email\" with \"#{email}\""
  step 'I fill in "Password" with "pass"'
  step 'I click "Log in"'

  @logged_in_user = @profile.user
end


Given /^some base students and teachers exist$/ do
  angela
  aditya
  ansh
  sahana
  john
end

def set_profile_password(profile, password)
  user = profile.user
  user.password = password
  user.save!
end

def create_profile(type, name, email=nil)
  first_name, last_name = split_name(name)
  email = mail_from_name(name) if email.nil?

  klass = type.capitalize.constantize

  obj = klass.create!(first_name: first_name, last_name: last_name, email: email)
  return obj
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

# Set up some standard users
def shalini
  @shalini ||= create_profile("teacher", "Shalini Sekhar")
end

def angela
  @angela ||= create_profile("teacher", "Angela Jain")
end

def aditya
  @aditya ||= create_profile("teacher", "Aditya Pandya")
end

def ansh
  @ansh ||= create_profile("student", "Ansh Something")
end

def sahana
  @sahana ||= create_profile("student", "Sahana Somethingelse")
end

def john
  @john ||= create_profile("student", "John Doe")
end