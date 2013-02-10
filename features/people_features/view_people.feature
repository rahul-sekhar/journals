@angular
Feature: View students and teachers

Unarchived students and teachers are both shown on the people page and. Only students, only teachers and archived students and teachers can also be viewed.

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

Scenario: View unarchived students and teachers on the people page
  When I am on the people page
  Then I should see the heading "Aditya Pandya"
  And I should see the heading "Angela Jain"
  And I should see the heading "Rahul Sekhar"
  And I should see the heading "Jim Dunlop"
  And I should see the heading "Ben Folds"
  And I should not see the heading "Tanu GB"
  And I should not see the heading "Archie Andrews"

@current
Scenario: View archived students and teachers on the people page
  When I am on the archived people page
  Then I should not see the heading "Aditya Pandya"
  And I should not see the heading "Angela Jain"
  And I should not see the heading "Rahul Sekhar"
  And I should not see the heading "Jim Dunlop"
  And I should not see the heading "Ben Folds"
  And I should see the heading "Tanu GB"
  And I should see the heading "Archie Andrews"

Scenario: View only students
  When I am on the students page
  Then I should not see the heading "Aditya Pandya"
  And I should not see the heading "Angela Jain"
  And I should not see the heading "Rahul Sekhar"
  And I should see the heading "Jim Dunlop"
  And I should see the heading "Ben Folds"
  And I should not see the heading "Tanu GB"
  And I should not see the heading "Archie Andrews"

Scenario: View only teachers
  When I am on the teachers page
  Then I should see the heading "Aditya Pandya"
  And I should see the heading "Angela Jain"
  And I should see the heading "Rahul Sekhar"
  And I should not see the heading "Jim Dunlop"
  And I should not see the heading "Ben Folds"
  And I should not see the heading "Tanu GB"
  And I should not see the heading "Archie Andrews"