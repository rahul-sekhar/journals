Feature: Manage milestones for a student and subject

Background:
  Given I have logged in as the teacher Rahul
  And the student John has some milestones set for Maths
  When I am on the work page
  And I select "John" from the students menu
  And I select "Maths" from the subjects menu


Scenario: View milestones done
  Then I should see "Framework"
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
  When I click "View and mark framework"
  Then I should see "Framework | Maths"
  And the milestone "Some milestone" should have the status 2
  And the milestone "Some milestone" should have the comment "Blah blah"
  And the milestone "Third" should have the status 3
  And the milestone "Third" should have no comment
  And the milestone "Middle milestone" should have the status 0
  And the milestone "Middle milestone" should have the comment "Some comment"
  And the milestone "Another one" should have the status 0
  And the milestone "Another one" should have no comment


Scenario: Edit milestones
  When I click "View and mark framework"
  Then I should see "Framework | Maths"
  When I set the milestone "Another one" to status 1 with the comment "New comment"
  Then the milestone "Another one" should have the status 1
  And the milestone "Another one" should have the comment "New comment"
  When I set the milestone "Some milestone" to status 3 with the comment "Changed comment"
  Then the milestone "Some milestone" should have the status 3
  And the milestone "Some milestone" should have the comment "Changed comment"
  When I set the milestone "Middle milestone" to status 0 with the comment ""
  Then the milestone "Middle milestone" should have the status 0
  And the milestone "Middle milestone" should have no comment
  When I set the milestone "Third" to status 0 with the comment ""
  Then the milestone "Third" should have the status 0
  And the milestone "Third" should have no comment

  When I go to the work page
  And I select "John" from the students menu
  And I select "Maths" from the subjects menu

  Then I should see "Another one"
  And I should not see "Third"
  And I should not see "Middle milestone"
  And I should see "Some milestone" in row 1 of the milestones table
  And I should see "completed" in row 1 of the milestones table
  And I should see "Changed comment" in row 1 of the milestones table
  And I should see "Another one" in row 2 of the milestones table
  And I should see "learning" in row 2 of the milestones table
  And I should see "New comment" in row 2 of the milestones table

  When I click "View and mark framework"
  Then I should see "Framework | Maths"
  And the milestone "Another one" should have the status 1
  And the milestone "Another one" should have the comment "New comment"
  And the milestone "Some milestone" should have the status 3
  And the milestone "Some milestone" should have the comment "Changed comment"
  And the milestone "Middle milestone" should have the status 0
  And the milestone "Middle milestone" should have no comment
  And the milestone "Third" should have the status 0
  And the milestone "Third" should have no comment