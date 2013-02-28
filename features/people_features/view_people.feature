@angular
Feature: View students and teachers and filter them

View various categories of people and filter them by their names.

Background:
  Given I have logged in as a teacher "Rahul Sekhar"
  And a student named "Jim Dunlop" exists
  And a teacher named "Angela Jain" exists
  And a teacher named "Aditya Pandya" exists
  And a teacher named "Tanu GB" exists
  And that teacher is archived
  And a student named "Ben Folds" exists
  And a student named "Archie Andrews" exists
  And that student is archived

@current
Scenario: View unarchived students and teachers on the people page
  When I am on the people page
  Then I should see the page heading "People"
  Then I should see the heading "Aditya Pandya"
  And I should see the heading "Angela Jain"
  And I should see the heading "Rahul Sekhar"
  And I should see the heading "Jim Dunlop"
  And I should see the heading "Ben Folds"
  And I should not see the heading "Tanu GB"
  And I should not see the heading "Archie Andrews"

  And I should see the field "search" within the "#upper-bar" block
  When I click "add" in a "p" element within the "#upper-bar" block
  Then I should see "add teacher" within the "#upper-bar" block
  And I should see "add student" within the "#upper-bar" block
  And I should see "manage groups" within the "#upper-bar" block
  And I should see "students and teachers" within the "#upper-bar" block

  When I fill in "search" with "a"
  And I should not see the heading "Jim Dunlop"
  And I should not see the heading "Ben Folds"
  Then I should see the heading "Aditya Pandya"
  And I should see the heading "Angela Jain"
  And I should see the heading "Rahul Sekhar"

  When I fill in "search" with "fo"
  Then I should not see the heading "Aditya Pandya"
  And I should not see the heading "Angela Jain"
  And I should not see the heading "Rahul Sekhar"
  And I should not see the heading "Jim Dunlop"
  And I should see the heading "Ben Folds"

Scenario: View archived students and teachers on the people page
  When I am on the people page
  And I click "students and teachers" in a ".title" element
  And I click "Archived students and teachers"
  Then I should be on the archived people page

  And I should see the page heading "People"
  Then I should not see the heading "Aditya Pandya"
  And I should not see the heading "Angela Jain"
  And I should not see the heading "Rahul Sekhar"
  And I should not see the heading "Jim Dunlop"
  And I should not see the heading "Ben Folds"
  And I should see the heading "Tanu GB"
  And I should see the heading "Archie Andrews"

  And I should see the field "search" within the "#upper-bar" block
  And I should see "add" within the "#upper-bar" block
  And I should see "archived students and teachers" within the "#upper-bar" block

  When I fill in "search" with "tan"
  And I should not see the heading "Archie Andrews"
  And I should see the heading "Tanu GB"

Scenario: View only students
  When I am on the people page
  And I click "students and teachers" in a ".title" element
  And I click the exact link "students"
  Then I should be on the students page

  Then I should see the page heading "People"
  Then I should not see the heading "Aditya Pandya"
  And I should not see the heading "Angela Jain"
  And I should not see the heading "Rahul Sekhar"
  And I should see the heading "Jim Dunlop"
  And I should see the heading "Ben Folds"
  And I should not see the heading "Tanu GB"
  And I should not see the heading "Archie Andrews"

  And I should see the field "search" within the "#upper-bar" block
  And I should see "add" within the "#upper-bar" block
  And I should see "students" within the "#upper-bar" block
  And I should not see "teachers" within the "#upper-bar" block

  When I fill in "search" with "jim dunlop"
  And I should not see the heading "Ben Folds"
  And I should see the heading "Jim Dunlop"

Scenario: View only teachers
  When I am on the people page
  And I click "students and teachers" in a ".title" element
  And I click "Teachers"
  Then I should be on the teachers page

  Then I should see the page heading "People"
  Then I should see the heading "Aditya Pandya"
  And I should see the heading "Angela Jain"
  And I should see the heading "Rahul Sekhar"
  And I should not see the heading "Jim Dunlop"
  And I should not see the heading "Ben Folds"
  And I should not see the heading "Tanu GB"
  And I should not see the heading "Archie Andrews"

  And I should see the field "search" within the "#upper-bar" block
  And I should see "add" within the "#upper-bar" block
  And I should see "teachers" within the "#upper-bar" block
  And I should not see "students" within the "#upper-bar" block

  When I fill in "search" with "RA"
  And I should not see the heading "Angela Jain"
  And I should see the heading "Rahul Sekhar"