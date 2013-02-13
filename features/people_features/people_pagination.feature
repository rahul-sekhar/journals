@angular
Feature: View pages of students and teachers

Pages with many people are paginated, with ten people per page

Background:
  Given I have logged in as a teacher "Rahul Sekhar"
  And a teacher for each alphabet exists
  And a student for each alphabet exists
  And an archived student for each alphabet exists

Scenario: View pages of people
  When I am on the people page
  Then I should see "A" in a "h3" element
  And I should see "E" in a "h3" element
  And I should not see "F" in a "h3" element
  And I should see "1" in a ".current-page" element