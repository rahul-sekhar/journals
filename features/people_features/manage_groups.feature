Feature: Manage groups and their students

Teachers can view and manage the groups for all students.

Background:
  Given I have logged in as a teacher "Rahul Sekhar"

Scenario: View a student with no groups
  Given a student profile for Parvathy exists
  And I am on the page for that profile
  Then I should see "Groups"
  And I should see "None" within the ".groups" block

Scenario: View a student with groups, add and remove groups
  Given a student profile for Parvathy exists
  And the groups "Group D, Group E" exist
  And that student belongs to the groups "Group A, Group B, Group C"
  And I am on the page for that profile
  Then I should see "Group A" within the ".groups ul" block
  And I should see "Group B" within the ".groups ul" block
  And I should see "Group C" within the ".groups ul" block
  And "Remaining groups" should have the options "Group D, Group E"

  When I select "Group E" from "Remaining groups"
  And I click "Add group"
  Then I should be on the page for that profile
  And I should see "Parvathy Manjunath has been added to the group "Group E""
  And I should see "Group E" within the ".groups ul" block
  And "Remaining groups" should have the options "Group D"

  When I click "Remove" near "Group B" in a list item
  Then I should be on the page for that profile
  And I should see "Parvathy Manjunath has been removed from the group "Group B""
  And I should not see "Group B" within the ".groups ul" block
  And "Remaining groups" should have the options "Group B, Group D"

Scenario: View all the students in a group
  Given PENDING the people page
