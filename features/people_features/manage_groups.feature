@current
Feature: Manage groups and their students

Teachers can view and manage the groups for all students.

Background:
  Given I have logged in as a teacher "Rahul Sekhar"

Scenario: View a student with no groups
  Given a student profile for Parvathy exists
  And I am on the page for that profile
  Then I should see "Groups"
  And I should see "None" within the ".groups" block
