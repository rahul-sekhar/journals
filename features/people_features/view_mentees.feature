Feature: View mentees

A teacher can view their own mentees by going to the mentees page. Students and Guardians should not be able to access this page

Scenario: View mentees as a student
  Given I have logged in as the student Rahul
  And I go to the people page
  Then the viewing menu should not have the option "Your mentees"

  When I go to the mentees page
  Then I should see "No matching people were found"

Scenario: View mentees as a guardian
  Given I have logged in as the guardian Rahul
  And I go to the people page
  Then the viewing menu should not have the option "Your mentees"

  When I go to the mentees page
  Then I should see "No matching people were found"

Scenario: View mentees as a teacher
  Given I have logged in as the teacher Rahul
  And a student "Lucky Sekhar" exists
  And a student "Roly Sekhar" exists
  And a student "Jumble Dog" exists
  And I have the mentees "Roly, Jumble"

  When I am on the people page
  Then the viewing menu should have the option "Your mentees"
  When I select "Your mentees" from the viewing menu
  Then I should be on the mentees page
  And I should see a profile for "Roly Sekhar"
  And I should not see a profile for "Lucky Sekhar"
  And I should see a profile for "Jumble Dog"

  And the add menu should not have the option "add teacher"
  And the add menu should not have the option "add student"
  And the add menu should have the option "manage groups"
  And the viewing menu should have "Your mentees" selected

  When I search for "sek"
  And I should see a profile for "Roly Sekhar"
  And I should not see a profile for "Lucky Sekhar"
  And I should not see a profile for "Jumble Dog"