@angular
Feature: View pages of students and teachers

Pages with many people are paginated, with ten people per page

Background:
  Given I have logged in as the teacher Rahul
  And a teacher for each alphabet exists
  And a student for each alphabet exists
  And all the students are my mentees
  And an archived student for each alphabet exists

Scenario: View pages of people
  When I am on the people page
  Then I should see a profile for "A"
  And I should see a profile for "E"
  And I should not see a profile for "F"
  And the selected page should be 1
  And the pages 1-6 should be visible

  When I select page 2
  And I should not see a profile for "E"
  And I should not see a profile for "K"
  And I should see a profile for "F"
  And I should see a profile for "J"
  And the selected page should be 2

  When I select page 6
  Then I should not see a profile for "F"
  And I should see a profile for "Z"
  And the selected page should be 6

Scenario: View pages of archived people
  When I am on the archived people page
  Then I should see a profile for "A"
  And I should see a profile for "J"
  And I should not see a profile for "K"
  And the selected page should be 1
  And the pages 1-3 should be visible

  When I select page 3
  Then I should not see a profile for "A"
  And I should see a profile for "Z"
  And the selected page should be 3

Scenario: View pages of teachers
  When I am on the teachers page
  Then I should see a profile for "A"
  And I should see a profile for "J"
  And I should not see a profile for "K"
  And the selected page should be 1
  And the pages 1-3 should be visible

  When I select page 3
  Then I should not see a profile for "A"
  And I should see a profile for "Z"
  And the selected page should be 3

Scenario: View pages of students
  When I am on the students page
  Then I should see a profile for "A"
  And I should see a profile for "J"
  And I should not see a profile for "K"
  And the selected page should be 1
  And the pages 1-3 should be visible

  When I select page 3
  Then I should not see a profile for "A"
  And I should see a profile for "Z"
  And the selected page should be 3

Scenario: View pages of mentees
  When I am on the mentees page
  Then I should see a profile for "A"
  And I should see a profile for "J"
  And I should not see a profile for "K"
  And the selected page should be 1
  And the pages 1-3 should be visible

  When I select page 3
  Then I should not see a profile for "A"
  And I should see a profile for "Z"
  And the selected page should be 3