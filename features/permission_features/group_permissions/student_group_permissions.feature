Feature: Group permissions for a student

As a student, I can view but not manage groups

Background:
  Given I have logged in as a student "Rahul Sekhar"


Scenario: View all the students in a group
  Given a group "Some Group" exists
  And that group has the students Roly, Lucky and Jumble
  And a student profile for Parvathy exists
  And I am on the page for that group
  Then I should see "Roly Sekhar"
  And I should see "Lucky Sekhar"
  And I should see "Jumble Sekhar"
  And I should not see "Parvathy Manjunath"


Scenario: Manage groups
  Then I should get a forbidden message when I go to the groups page