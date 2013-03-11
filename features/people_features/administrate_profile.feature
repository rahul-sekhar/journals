@angular
Feature: Perform administrative functions on a profile

Teachers can activate a profile, reset its password, archive it and delete it

Background:
  Given I have logged in as the teacher Rahul


Scenario: Delete a teacher from the people page
  Given a teacher Shalini exists
  When I am on the people page
  Then I should see a profile for "Shalini Sekhar"

  When I look at the profile for "Shalini Sekhar"
  And I select "Delete" from the manage menu in it
  Then I should not see a profile for "Shalini Sekhar"

  When I go to the people page
  Then I should not see a profile for "Shalini Sekhar"


Scenario: Delete a student from their profile
  Given a student Parvathy exists
  When I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  And I select "Delete" from the manage menu in it
  Then the page heading should be "People"
  And I should be on the people page
  And I should see "Parvathy Manjunath has been deleted"


Scenario: Delete a guardian when the guardian has only one student
  Given a student Parvathy exists
  And a guardian "Manoj Jain" exists for that student
  When I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  And I look at the guardian "Manoj Jain"
  
  When I select "Delete" from the manage menu in it
  And I look at the profile for "Parvathy Manjunath"
  Then I should not see the guardian "Manoj Jain"

  When I go to the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  Then I should not see the guardian "Manoj Jain"


Scenario: Remove a guardian when the guardian has multiple students
  Given a guardian Manoj with multiple students exists
  When I am on the people page
  And I look at the profile for "Roly Jain"
  And I look at the guardian "Manoj Jain"
  
  When I select "Remove" from the manage menu in it
  And I look at the profile for "Roly Jain"
  Then I should not see the guardian "Manoj Jain"

  When I look at the profile for "Parvathy Manjunath"
  Then I should see the guardian "Manoj Jain"
  
  When I go to the people page
  And I look at the profile for "Roly Jain"
  Then I should not see the guardian "Manoj Jain"
  When I look at the profile for "Parvathy Manjunath"
  Then I should see the guardian "Manoj Jain"


Scenario: Activate a teacher with no email address
  Given a teacher Shalini exists
  And the profile has no email address
  When I am on the page for that profile
  And I look at the profile for "Shalini Sekhar"
  Then the manage menu should not have the option "Activate" in it


Scenario: Activate a teacher
  Given a teacher Shalini exists
  When I am on the page for that profile
  And I look at the profile for "Shalini Sekhar"
  And I select "Activate" from the manage menu in it
  Then I should see "An email has been sent to shalini.sekhar@mail.com with a randomly generated password"
  And the manage menu should not have the option "Activate" in it
  And the manage menu should have the option "Reset password" in it
  
  And "shalini.sekhar@mail.com" should receive an email
  When they open the email
  Then they should see /^Activate your account$/ in the email subject

  When I go to the page for that profile
  And I look at the profile for "Shalini Sekhar"
  Then the manage menu should not have the option "Activate" in it
  And the manage menu should have the option "Reset password" in it


Scenario: Reset the password for a teacher
  Given a teacher Shalini exists
  And the profile has been activated
  When I am on the page for that profile
  And I look at the profile for "Shalini Sekhar"
  And I select "Reset password" from the manage menu in it
  Then I should see "An email has been sent to shalini.sekhar@mail.com with a randomly generated password"
  
  And "shalini.sekhar@mail.com" should receive an email
  When they open the email
  Then they should see /^Your password has been reset$/ in the email subject


Scenario: Activate a student with no email address
  Given a student Parvathy exists
  And the profile has no email address
  When I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  Then the manage menu should not have the option "Activate" in it


Scenario: Activate a student
  Given a student Parvathy exists
  When I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  And I select "Activate" from the manage menu in it
  Then I should see "An email has been sent to parvathy.manjunath@mail.com with a randomly generated password"
  
  And "parvathy.manjunath@mail.com" should receive an email
  When they open the email
  Then they should see /^Activate your account$/ in the email subject

  When I go to the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  Then the manage menu should not have the option "Activate" in it
  And the manage menu should have the option "Reset password" in it


Scenario: Activate a guardian with no email address
  Given a student Parvathy exists
  And a guardian Poonam exists for that student
  And the guardian has no email address
  When I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  And I look at the guardian "Poonam Jain"
  Then the manage menu should not have the option "Activate" in it


Scenario: Activate a guardian with an email address
  Given a student Parvathy exists
  And a guardian Poonam exists for that student
  When I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  And I look at the guardian "Poonam Jain"
  And I select "Activate" from the manage menu in it
  Then I should see "An email has been sent to poonam@mail.com with a randomly generated password"
  
  And "poonam@mail.com" should receive an email
  When they open the email
  Then they should see /^Activate your account$/ in the email subject

  When I go to the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  And I look at the guardian "Poonam Jain"
  Then the manage menu should not have the option "Activate" in it
  And the manage menu should have the option "Reset password" in it


Scenario: Archive and unarchive a teacher
  Given a teacher Shalini exists
  When I am on the page for that profile
  And I look at the profile for "Shalini Sekhar"
  Then the manage menu should not have the option "Unarchive" in it
  
  When I select "Archive" from the manage menu in it
  Then I should see "Shalini Sekhar has been archived and can no longer login"
  And the manage menu should not have the option "Archive" in it

  When I go to the page for that profile
  And I look at the profile for "Shalini Sekhar"
  Then the manage menu should not have the option "Archive" in it
  And the manage menu should have the option "Unarchive" in it

  When I select "Unarchive" from the manage menu in it
  Then I should see "Shalini Sekhar is no longer archived, but must be activated to be able to login"
  And the manage menu should not have the option "Unarchive" in it
  And the manage menu should have the option "Archive" in it

  When I go to the page for that profile
  And I look at the profile for "Shalini Sekhar"
  And the manage menu should not have the option "Unarchive" in it
  And the manage menu should have the option "Archive" in it


Scenario: Archive and unarchive a student
  Given a student Parvathy exists
  When I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  Then the manage menu should not have the option "Unarchive" in it
  
  When I select "Archive" from the manage menu in it
  Then I should see "Parvathy Manjunath has been archived and can no longer login"
  And the manage menu should not have the option "Archive" in it

  When I go to the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  Then the manage menu should not have the option "Archive" in it
  And the manage menu should have the option "Unarchive" in it

  When I select "Unarchive" from the manage menu in it
  Then I should see "Parvathy Manjunath is no longer archived, but must be activated to be able to login"
  And the manage menu should not have the option "Unarchive" in it
  And the manage menu should have the option "Archive" in it

  When I go to the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  And the manage menu should not have the option "Unarchive" in it
  And the manage menu should have the option "Archive" in it