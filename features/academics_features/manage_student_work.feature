Feature: Manage uits and milestones for a student and subject

Background:
  Given I have logged in as the teacher Rahul
  And the student John has done some work on Maths
  And I am on the work page


Scenario: View units done
  Then the page heading should be "Academic records"
  And I should see "Please select a student and a subject"
  And I should not see "Work log"
  And I should not see "Framework"

  When I select "John" from the students menu
  And I select "Maths" from the subjects menu
  Then I should not see "Please select a student and a subject"
  And I should see "Work log"
  And I should see "Unit 1"
  And I should see "05-05-2011"
  And I should see "Unit 2"
  And I should see "10-01-2010"
  And I should see "10-05-2010"
  And I should see "06-05-2010"
  And I should see "Well done!"
  And I should not see "Unwanted Unit"


Scenario: Edit unit
  When I select "John" from the students menu
  And I select "Maths" from the subjects menu

  And I look at the unit "Unit 1"

  And I change the name field to "Changed unit"
  Then I should not see "Unit 1"
  And I should see "Changed unit"

  When I change the due date field to "25-10-2009"
  Then I should see "25-10-2009"

  And I clear the started date field
  Then I should not see "05-05-2011"

  When I change the comments field to "Some comments"
  Then I should see "Some comments"

  When I go to the work page
  And I select "John" from the students menu
  And I select "Maths" from the subjects menu
  Then I should not see "Unit 1"
  And I should see "Changed unit"
  And I should not see "05-05-2011"
  And I should see "25-10-2009"
  And I should not see "05-05-2011"
  And I should see "Some comments"


Scenario: Add unit
  When I select "John" from the students menu
  And I select "Maths" from the subjects menu

  And I add the unit "New unit"
  Then I should see "New unit"

  When I go to the work page
  And I select "John" from the students menu
  And I select "Maths" from the subjects menu
  Then I should see "Unit 1"
  And I should see "Unit 2"
  And I should see "New unit"


Scenario: Delete unit
  When I select "John" from the students menu
  And I select "Maths" from the subjects menu

  And I delete the unit "Unit 1"
  Then I should not see "Unit 1"

  When I go to the work page
  And I select "John" from the students menu
  And I select "Maths" from the subjects menu
  Then I should not see "Unit 1"
  And I should see "Unit 2"