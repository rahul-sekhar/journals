Feature: View units and milestones as a guardian

Background:
  Given I have logged in as the guardian Rahul
  And I have a student "Lucky Sekhar"


Scenario: View a student with no subjects
  Given the students Jumble exist
  When I am on the work page
  Then I should not see "manage subjects"
  Then I should see "Please select a student"
  And I should see the students menu
  And the students menu should have the option "Roly"
  And the students menu should have the option "Lucky"
  And the students menu should not have the option "Jumble"
  And I should not see the subjects menu

  When I select "Lucky" from the students menu
  Then I should see "This student does not have any associated subjects yet"
  And I should not see the subjects menu


Scenario: View a student with subjects
  Given my student Roly has done some work on Maths
  And my student Roly has a few more subjects
  When I go to the work page
  And I select "Roly" from the students menu
  Then I should not see "This student does not have any associated subjects yet"
  And I should see "Please select a subject"
  And I should see the subjects menu
  And the subjects menu should have the option "Maths"
  And the subjects menu should have the option "English"
  And the subjects menu should not have the option "History"


Scenario: View units done
  Given my student Roly has done some work on Maths
  When I go to the work page
  And I select "Roly" from the students menu
  And I select "Maths" from the subjects menu
  Then I should see "Work log"
  And I should see "Unit 1"
  And I should see "05-05-2011"
  And I should see "Unit 2"
  And I should see "10-01-2010"
  And I should see "10-05-2010"
  And I should see "06-05-2010"
  And I should see "Well done!"
  And I should not see "Unwanted Unit"

  When I look at the unit "Unit 1"
  Then I should not be able to change the name field
  And I should not be able to delete the unit
  And I should not be able to add a unit


Scenario: View milestones done
  Given my student Roly has some milestones set for Maths
  When I go to the work page
  And I select "Roly" from the students menu
  And I select "Maths" from the subjects menu
  And I should see "Blah blah"
  And I should see "Blah blah" in row 2 of the milestones table
  And I should see "Some milestone" in row 2 of the milestones table
  And I should see "having difficulty" in row 2 of the milestones table
  And I should see "Third" in row 1 of the milestones table
  And I should see "completed" in row 1 of the milestones table
  And I should not see "Another one"
  And I should see "Middle milestone" in row 3 of the milestones table
  And I should see "Some comment" in row 3 of the milestones table
  And I should see "no status" in row 3 of the milestones table
  And I should see "01-10-2012" in row 3 of the milestones table


Scenario: View milestones on the framework
  Given my student Roly has some milestones set for Maths
  When I go to the work page
  And I select "Roly" from the students menu
  And I select "Maths" from the subjects menu
  Then the subjects menu should have "Maths" selected
  And I click "View framework"
  Then I should see "Framework | Maths"
  And the milestone "Some milestone" should have the status 2
  And the milestone "Some milestone" should have the comment "Blah blah"
  And the milestone "Third" should have the status 3
  And the milestone "Third" should have no comment
  And the milestone "Middle milestone" should have no status
  And the milestone "Middle milestone" should have the comment "Some comment"
  And the milestone "Another one" should have no status
  And the milestone "Another one" should have no comment

  And I should not be able to set the milestone "Another one"