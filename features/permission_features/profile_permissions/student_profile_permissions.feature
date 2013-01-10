Feature: Profile permissions for a student

As a student, I can view any profile and edit my own.

Background:
  Given I have logged in as a student "Rahul Sekhar"


Scenario: View a teacher profile
  Given a teacher named "Shalini Sekhar" exists
  And the students Roly, Lucky and Jumble exist
  And that profile has the mentees "Roly"
  When I am on the page for that profile
  Then I should not see "Edit profile"

  And I should not see "Archive user"
  And I should not see "Delete user"
  And I should not see "Activate user"

  And I should not see "Remove" within the ".mentees" block
  And I should not see the button "Add mentee"

  And I should get a forbidden message when I go to the edit page for that profile



Scenario: View a student profile
  Given a student named "Parvathy Manjunath" exists
  And the teachers Angela, Shalini, Aditya and Sharad exist
  And that student belongs to the mentors "Angela, Aditya"
  And the groups "Some Group, Other Group" exist
  And that student belongs to the groups "Some Group"
  When I am on the page for that profile
  Then I should not see "Edit profile"

  And I should not see "Archive user"
  And I should not see "Delete user"
  And I should not see "Activate user"

  And I should not see "Remove" within the ".mentors" block
  And I should not see the button "Add mentor"

  And I should not see "Remove" within the ".groups" block
  And I should not see the button "Add group"

  And I should not see "Add guardian"

  And I should get a forbidden message when I go to the edit page for that profile
  And I should get a forbidden message when I go to the create guardian page for that profile



Scenario: View my own profile
  Given the teachers Angela, Shalini, Aditya and Sharad exist
  And I belong to the mentors "Angela, Aditya"
  And I have the guardian "Archana Sekhar"
  And the groups "Some Group, Other Group" exist
  And I belong to the groups "Some Group"
  When I am on the page for my profile
  Then I should see "Edit profile"

  And I should not see "Archive user"
  And I should not see "Delete user"
  And I should not see "Activate user"

  And I should not see "Remove" within the ".mentors" block
  And I should not see the button "Add mentor"

  And I should not see "Remove" within the ".groups" block
  And I should not see the button "Add group"

  And I should not see "Add guardian"

  When I click "Edit profile"
  Then I should be on the edit page for my profile
  And I should get a forbidden message when I go to the create guardian page for my profile



Scenario: View a guardian
  Given a student named "Parvathy Manjunath" exists
  And a guardian Manoj for that student exists
  When I am on the page for that profile
  Then I should not see "Edit profile" within the ".guardians" block

  And I should not see "Delete user" within the ".guardians" block
  And I should not see "Activate user" within the ".guardians" block

  And I should get a forbidden message when I go to the edit page for the guardian


Scenario: Create users
  When I am on the people page
  Then I should not see "Add student"
  And I should not see "Add teacher"

  And I should get a forbidden message when I go to the new student page
  And I should get a forbidden message when I go to the new teacher page
