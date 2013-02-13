@angular
Feature: View a profile

I should be able to view a student, guardian or teacher's profile and see all stored information about them. I should be able to reach the profile by clicking on their name anywhere else on the site (for example if they authored a post)

Background:
  Given I have logged in as a teacher "Rahul Sekhar"

Scenario: View teacher profile with minimal information
  Given a student profile for Parvathy exists
  And a teacher profile for Shalini exists
  When I am on the page for that profile
  Then I should see the page heading "Profile: Shalini Sekhar"
  And I should not see "Parvathy Manjunath"
  And I should see "Teacher"
  And I should see "Email" in a ".field-name" element
  And I should see "shalini@mail.com"
  And I should not see "Mobile" in a ".field-name" element
  And I should not see "Address" in a ".field-name" element
  And I should not see "Home Phone" in a ".field-name" element
  And I should not see "Office Phone" in a ".field-name" element
  And I should not see "Additional Emails" in a ".field-name" element
  And I should not see "Notes" in a ".field-name" element

Scenario: View teacher profile with all information
  Given a teacher profile for Shalini with all information exists
  When I am on the page for that profile
  Then I should see the page heading "Profile: Shalini Sekhar"
  And I should see "Teacher"
  And I should see "Email" in a ".field-name" element
  And I should see "shalini@mail.com"
  And I should see "Mobile" in a ".field-name" element
  And I should see "1122334455"
  And I should see "Address" in a ".field-name" element
  And I should see "Some house, Banashankari, Bangalore - 55"
  And I should see "Home Phone" in a ".field-name" element
  And I should see "080-12345"
  And I should see "Office Phone" in a ".field-name" element
  And I should see "080-67890"
  And I should see "Additional Emails" in a ".field-name" element
  And I should see "shalu@short.com, shalini_sekhar@long.com"
  And I should see "Notes" in a ".field-name" element
  And I should see "A test sister"

Scenario: View student profile with all information
  Given a teacher profile for Shalini exists
  And a student profile for Parvathy with all information exists
  When I am on the page for that profile
  Then I should see the page heading "Profile: Parvathy Manjunath"
  And I should not see "Shalini Sekhar"
  And I should see "Email" in a ".field-name" element
  And I should see "parvathy@mail.com"
  And I should see "Mobile" in a ".field-name" element
  And I should see "12345678"
  And I should see "Address" in a ".field-name" element
  And I should see "Apartment, The hill, Darjeeling - 10"
  And I should see "Home Phone" in a ".field-name" element
  And I should see "5678"
  And I should see "Office Phone" in a ".field-name" element
  And I should see "1432"
  And I should see "Birthday" in a ".field-name" element
  And I should see "25-12-1996 (16 yrs)"
  And I should see "Blood Group" in a ".field-name" element
  And I should see "B+"

Scenario: View a student profile containing a guardian profile with minimal information
  Given a student profile for Parvathy exists
  And a guardian Manoj for that student exists
  When I am on the page for that profile
  Then I should see the page heading "Profile: Parvathy Manjunath"
  And I should see "Manoj Jain" within the ".guardians" block
  And I should not see "Email" in a ".field-name" element within the ".guardians" block
  And I should not see "Mobile" in a ".field-name" element within the ".guardians" block
  And I should not see "Address" in a ".field-name" element within the ".guardians" block
  And I should not see "Home Phone" in a ".field-name" element within the ".guardians" block
  And I should not see "Office Phone" in a ".field-name" element within the ".guardians" block

Scenario: View a student profile containing multiple guardians
  Given a student profile for Parvathy exists
  And a guardian Manoj for that student exists
  And a guardian Poonam for that student exists
  When I am on the page for that profile
  And I should see the page heading "Profile: Parvathy Manjunath"
  And I should see "Manoj Jain" within the ".guardians" block
  And I should see "Poonam Jain" within the ".guardians" block
  And I should see "Email" in a ".field-name" element within the ".guardians" block
  And I should see "poonam@mail.com"
  And I should see "Mobile" in a ".field-name" element within the ".guardians" block
  And I should see "987654"
  And I should see "Address" in a ".field-name" element within the ".guardians" block
  And I should see "A house, Somewhere"
  And I should see "Home Phone" in a ".field-name" element within the ".guardians" block
  And I should see "111-222"
  And I should see "Office Phone" in a ".field-name" element within the ".guardians" block
  And I should see "333-444"


Scenario: View a guardian profile with multiple students
  Given a teacher profile for Shalini exists
  And a guardian Manoj with multiple students exists
  When I am on the page for that profile
  Then I should see the page heading "Profile: Manoj Jain"
  Then I should see "Parvathy Manjunath"
  And I should see "Roly Jain"
  And I should not see "Shalini Sekhar"
  Given PENDING page headings

Scenario: Click on users name to reach profile
  Given PENDING posts page
  Given a post titled "Some Post" created by me exists
  And I am on the page for that post
  When I click "Rahul Sekhar" within the ".info" block
  Then I should be on the page for my profile
  And I should see "Rahul Sekhar"