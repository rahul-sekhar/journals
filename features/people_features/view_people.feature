Feature: View students and teachers and filter them

View various categories of people and filter them by their names.

Background:
  Given I have logged in as the teacher Rahul
  And a student "Jim Dunlop" exists
  And a teacher "Angela Jain" exists
  And a teacher "Aditya Pandya" exists
  And an archived teacher "Tanu GB" exists
  And a student "Ben Folds" exists
  And an archived student "Archie Andrews" exists


Scenario: View unarchived students and teachers on the people page
  When I am on the people page
  Then the page heading should be "People"
  And I should see a profile for "Aditya Pandya"
  And I should see a profile for "Angela Jain"
  And I should see a profile for "Rahul Sekhar"
  And I should see a profile for "Jim Dunlop"
  And I should see a profile for "Ben Folds"
  And I should not see a profile for "Tanu GB"
  And I should not see a profile for "Archie Andrews"

  And the add menu should have the option "add teacher"
  And the add menu should have the option "add student"
  And the add menu should have the option "manage groups"
  And I should see "viewing" in the filter bar
  And the viewing menu should have "Students and teachers" selected


Scenario: View archived students and teachers on the people page
  When I am on the people page
  And I select "Archived students and teachers" from the viewing menu
  And the page heading should be "People"

  Then I should not see a profile for "Aditya Pandya"
  And I should not see a profile for "Angela Jain"
  And I should not see a profile for "Rahul Sekhar"
  And I should not see a profile for "Jim Dunlop"
  And I should not see a profile for "Ben Folds"
  And I should see a profile for "Tanu GB"
  And I should see a profile for "Archie Andrews"

  And the viewing menu should have "Archived students and teachers" selected
  And the add menu should have the option "manage groups"
  And the add menu should have the option "add teacher"
  And the add menu should have the option "add student"

Scenario: View only students
  When I am on the people page
  And I select "Students" from the viewing menu
  And the page heading should be "People"

  And I should not see a profile for "Aditya Pandya"
  And I should not see a profile for "Angela Jain"
  And I should not see a profile for "Rahul Sekhar"
  And I should see a profile for "Jim Dunlop"
  And I should see a profile for "Ben Folds"
  And I should not see a profile for "Tanu GB"
  And I should not see a profile for "Archie Andrews"

  And the viewing menu should have "Students" selected
  And the add menu should have the option "add student"
  And the add menu should have the option "manage groups"
  And the add menu should have the option "add teacher"

Scenario: View only teachers
  When I am on the people page
  And I select "Teachers" from the viewing menu
  And the page heading should be "People"

  And I should see a profile for "Aditya Pandya"
  And I should see a profile for "Angela Jain"
  And I should see a profile for "Rahul Sekhar"
  And I should not see a profile for "Jim Dunlop"
  And I should not see a profile for "Ben Folds"
  And I should not see a profile for "Tanu GB"
  And I should not see a profile for "Archie Andrews"

  And the viewing menu should have "Teachers" selected
  And the add menu should have the option "add teacher"
  And the add menu should have the option "manage groups"
  And the add menu should have the option "add student"
