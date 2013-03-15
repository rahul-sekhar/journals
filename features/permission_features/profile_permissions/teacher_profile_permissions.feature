@angular @current
Feature: Profile permissions for a teacher

As a teacher, I can view, edit and administrate any profile

Background:
  Given I have logged in as a teacher "Rahul Sekhar"


Scenario: Manage a teacher profile
  Given a teacher named "Shalini Sekhar" exists
  And the students Roly, Lucky and Jumble exist
  And that profile has the mentees "Roly"
  When I am on the page for that profile
  Then I should see "Edit profile"

  And I should see "Archive user"
  And I should see "Delete user"
  And I should see "Activate user"

  And I should see "Remove" within the ".mentees" block
  And I should see the button "Add" within the ".mentees" block

  When I click "Edit profile"
  Then I should be on the edit page for that profile



Scenario: Manage a student profile
  Given a student named "Parvathy Manjunath" exists
  And the teachers Angela, Shalini, Aditya and Sharad exist
  And that student belongs to the mentors "Angela, Aditya"
  And the groups "Some Group, Other Group" exist
  And that student belongs to the groups "Some Group"
  When I am on the page for that profile
  Then I should see "Edit profile"

  And I should see "Archive user"
  And I should see "Delete user"
  And I should see "Activate user"

  And I should see "Remove" within the ".mentors" block
  And I should see the button "Add" within the ".mentors" block

  And I should see "Remove" within the ".groups" block
  And I should see the button "Add" within the ".groups" block

  And I should see "Add guardian"

  When I click "Edit profile"
  Then I should be on the edit page for that profile

  When I am on the page for that profile
  And I click "Add guardian"
  Then I should be on the create guardian page for that profile



Scenario: Manage a guardian
  Given a student named "Parvathy Manjunath" exists
  And a guardian Manoj for that student exists
  When I am on the page for that profile
  Then I should see "Edit profile" within the ".guardians" block

  And I should see "Delete user" within the ".guardians" block
  And I should see "Activate user" within the ".guardians" block

  When I click "Edit profile" within the ".guardians" block
  Then I should be on the edit page for the guardian


Scenario: Create users
  When I am on the people page
  Then I should see "Add student"
  And I should see "Add teacher"

  When I click "Add student"
  Then I should be on the new student page

  When I am on the people page
  And I click "Add teacher"
  Then I should be on the new teacher page
