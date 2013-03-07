@angular
Feature: View a profile

I should be able to view a student, guardian or teacher's profile and see all stored information about them. I should be able to reach the profile by clicking on their name anywhere else on the site (for example if they authored a post)

Background:
  Given I have logged in as the teacher Rahul


Scenario: View teacher profile with minimal information
  Given a student "Parvathy Manjunath" exists
  And a teacher "Shalini Sekhar" exists
  When I am on the page for that profile
  Then the page heading should be "Profile: Shalini Sekhar"
  And I should not see a profile for "Parvathy Manjunath"

  When I look at the profile for "Shalini Sekhar"
  Then I should see "Teacher" in it
  And I should see the field "Email" with "shalini.sekhar@mail.com"
  And I should not see the field "Mobile"
  And I should not see the field "Address"
  And I should not see the field "Home Phone"
  And I should not see the field "Office Phone"
  And I should not see the field "Additional Emails"
  And I should not see the field "Notes"

  And I should not see the search bar
  And I should not see the add menu
  And I should not see "viewing" in the filter bar


Scenario: View teacher profile with all information
  Given a teacher Shalini exists
  When I am on the page for that profile

  When I look at the profile for "Shalini Sekhar"
  Then I should see "Teacher"
  And I should see the field "Email" with "shalini.sekhar@mail.com"
  And I should see the field "Mobile" with "1122334455"
  And I should see the field "Address" with "Some house, Banashankari, Bangalore - 55"
  And I should see the field "Home Phone" with "080-12345"
  And I should see the field "Office Phone" with "080-67890"
  And I should see the field "Additional Emails" with "shalu@short.com, shalini_sekhar@long.com"
  And I should see the field "Notes" with "A test sister"


Scenario: View student profile with all information
  Given a teacher "Shalini Sekhar" exists
  And a student Parvathy exists
  When I am on the page for that profile
  Then the page heading should be "Profile: Parvathy Manjunath"
  And I should not see a profile for "Shalini Sekhar"

  When I look at the profile for "Parvathy Manjunath"
  Then I should see the field "Email" with "parvathy.manjunath@mail.com"
  And I should see the field "Mobile" with "12345678"
  And I should see the field "Address" with "Apartment, The hill, Darjeeling - 10"
  And I should see the field "Home Phone" with "5678"
  And I should see the field "Office Phone" with "1432"
  And I should see the field "Birthday" with "25-12-1996 (16 yrs)"
  And I should see the field "Blood Group" with "B+"

  And I should not see the search bar
  And I should not see the add menu
  And I should not see "viewing" in the filter bar


Scenario: View a student profile containing a guardian profile with minimal information
  Given a student "Parvathy Manjunath" exists
  And a guardian "Manoj Jain" exists for that student
  When I am on the page for that profile
  Then the page heading should be "Profile: Parvathy Manjunath"

  When I look at the profile for "Parvathy Manjunath"
  Then I should see the guardian "Manoj Jain"
  When I look at the guardian "Manoj Jain"
  Then I should not see the field "Email"
  And I should not see the field "Mobile"
  And I should not see the field "Address"
  And I should not see the field "Home Phone"
  And I should not see the field "Office Phone"


Scenario: View a student profile containing multiple guardians
  Given a student "Parvathy Manjunath" exists
  And a guardian "Manoj Jain" exists for that student
  And a guardian Poonam exists for that student
  
  When I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  Then I should see the guardian "Manoj Jain"
  And I should see the guardian "Poonam Jain"
  When I look at the guardian "Poonam Jain"
  Then I should see the field "Email" with "poonam@mail.com"
  And I should see the field "Mobile" with "987654"
  And I should see the field "Address" with "A house, Somewhere"
  And I should see the field "Home Phone" with "111-222"
  And I should see the field "Office Phone" with "333-444"


Scenario: View a guardian profile with multiple students
  Given a teacher "Shalini Sekhar" exists
  And a guardian Manoj with multiple students exists
  When I am on the page for that profile
  Then the page heading should be "Profile: Manoj Jain"

  Then I should see a profile for "Parvathy Manjunath"
  And I should see a profile for "Roly Jain"
  And I should not see a profile for "Shalini Sekhar"

  And I should not see the search bar
  And I should not see the add menu
  And I should not see "viewing" in the filter bar


Scenario: Click on users name to reach profile
  Given PENDING posts page
  Given a post titled "Some Post" created by me exists
  And I am on the page for that post
  When I click "Rahul Sekhar" within the ".info" block
  Then I should be on the page for my profile
  And I should see "Rahul Sekhar"