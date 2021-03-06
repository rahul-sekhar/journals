Feature: View a summary of academic records

Scenario: View academic records summary as a Teacher
  Given I have logged in as the teacher Rahul
  And I teach some students with academic work done
  When I am on the academics page
  Then I should see "John Maths"
  And I should not see "John English"
  Then I should not see "William Maths"
  And I should see "William English"
  And I should see "Tyler Maths"
  And I should see "Tyler English"
  And I should not see "Psychology"

  And I should see "Test unit"
  And I should not see "Other unit"
  And I should see "02-10-2010"
  And I should see "edited 01-01-2009"


Scenario: View academic records summary as a student
  Given I have logged in as the student Rahul
  And I have some academic work done
  When I am on the academics page
  Then I should see "Rahul Maths"
  And I should see "Rahul English"
  And I should not see "John Maths"
  And I should not see "John English"
  And I should not see "Psychology"

  And I should see "Test unit"
  And I should not see "Other unit"
  And I should see "02-10-2010"
  And I should see "edited 01-01-2009"


Scenario: View academic records summary as a guardian
  Given I have logged in as the guardian Rahul
  And my students have some academic work done
  When I am on the academics page
  Then I should see "Roly Maths"
  And I should see "Roly English"
  And I should see "Lucky Maths"
  And I should not see "Lucky English"
  And I should not see "John Maths"
  And I should not see "John English"
  And I should not see "Psychology"

  And I should see "Test unit"
  And I should not see "Other unit"
  And I should see "02-10-2010"
  And I should see "edited 01-01-2009"
