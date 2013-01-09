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
  Given a group "Some Group" exists
  And that group has the students Roly, Lucky and Jumble
  And a student profile for Parvathy exists
  And I am on the page for that group
  Then I should see "Roly Sekhar"
  And I should see "Lucky Sekhar"
  And I should see "Jumble Sekhar"
  And I should not see "Parvathy Manjunath"

Scenario: View a group with no students
  Given a group "Some Group" exists
  And I am on the page for that group
  Then I should see "There are no students in this group yet"

Scenario: View the groups page with no groups
  When I am on the groups page
  Then I should see "There are no groups yet"

Scenario: View the groups page when there are groups
  Given the groups "Group 1, Group 2" exist
  When I am on the groups page
  Then I should see "Group 1" within the ".groups" block
  And I should see "Group 2" within the ".groups" block

Scenario: Delete a group
  Given the groups "Group 1, Group 2" exist
  When I am on the groups page
  And I click "Delete" near "Group 1" in a list item
  Then I should be on the groups page
  And I should see ""Group 1" has been deleted"
  And I should see "Group 2" within the ".groups" block
  And I should not see "Group 1" within the ".groups" block

Scenario: Edit a group
  Given the groups "Group 1, Group 2" exist
  When I am on the groups page
  And I click "Rename" near "Group 1" in a list item
  And I fill in "Name" with "Different Name"
  And I click "Save"
  And I should see ""Group 1" has been renamed to "Different Name""
  And I should see "Group 2" within the ".groups" block
  And I should see "Different Name" within the ".groups" block
  And I should not see "Group 1" within the ".groups" block

Scenario: Add a group
  When I am on the people page
  And I click "Add group"
  And I fill in "Name" with "New Group"
  And I click "Create"
  Then I should be on the people page
  And I should see "The group "New Group" has been created"
  And I should see "New Group"