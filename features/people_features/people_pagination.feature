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
  And I should see "1" in a "#pagination .current" element
  And I should see "1 2 3 4 5 6" within the "#pagination" block
  And I should not see "7" within the "#pagination" block

  When I click "2" within the "#pagination" block
  Then I should be on the people page
  And I should see "F" in a "h3" element
  And I should see "J" in a "h3" element
  And I should not see "E" in a "h3" element
  And I should not see "K" in a "h3" element
  And I should see "2" in a "#pagination .current" element

  When I click "6" within the "#pagination" block
  Then I should be on the people page
  And I should see "Z" in a "h3" element
  And I should see "6" in a "#pagination .current" element

Scenario: View pages of archived people
  When I am on the archived people page
  Then I should see "A" in a "h3" element
  And I should see "J" in a "h3" element
  And I should not see "K" in a "h3" element
  And I should see "1" in a "#pagination .current" element
  And I should see "1 2 3" within the "#pagination" block
  And I should not see "4" within the "#pagination" block

  When I click "3" within the "#pagination" block
  Then I should be on the archived people page
  And I should see "Z" in a "h3" element
  And I should see "3" in a "#pagination .current" element

Scenario: View pages of teachers
  When I am on the teachers page
  Then I should see "A" in a "h3" element
  And I should see "J" in a "h3" element
  And I should not see "K" in a "h3" element
  And I should see "1" in a "#pagination .current" element
  And I should see "1 2 3" within the "#pagination" block
  And I should not see "4" within the "#pagination" block

  When I click "3" within the "#pagination" block
  Then I should be on the teachers page
  And I should see "Z" in a "h3" element
  And I should see "3" in a "#pagination .current" element

Scenario: View pages of students
  When I am on the students page
  Then I should see "A" in a "h3" element
  And I should see "J" in a "h3" element
  And I should not see "K" in a "h3" element
  And I should see "1" in a "#pagination .current" element
  And I should see "1 2 3" within the "#pagination" block
  And I should not see "4" within the "#pagination" block

  When I click "3" within the "#pagination" block
  Then I should be on the students page
  And I should see "Z" in a "h3" element
  And I should see "3" in a "#pagination .current" element