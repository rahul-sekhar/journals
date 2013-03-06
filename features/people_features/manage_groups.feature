@angular
Feature: Manage groups and their students

Teachers can view and manage the groups for all students.

Background:
  Given I have logged in as a teacher "Rahul Sekhar"


Scenario: View the groups dialog with no groups
  When I open the manage groups dialog
  
  Then I should see the heading "Manage groups"
  And I should see "There are no groups yet"


Scenario: View the groups page when there are groups
  Given the groups "Group 1, Group 2" exist
  When I open the manage groups dialog
  Then I should see "Group 1" within the "#groups" block
  And I should see "Group 2" within the "#groups" block


Scenario: Delete a group
  Given the groups "Group 1, Group 2" exist
  When I open the manage groups dialog
  And I click the element ".delete" near "Group 1" in a list item
  Then I should not see "Group 1" within the "#groups" block
  And I should see "Group 2" within the "#groups" block

  When I open the manage groups dialog
  Then I should see "Group 2" within the "#groups" block
  And I should not see "Group 1" within the "#groups" block


Scenario: Edit a group
  Given the groups "Group 1, Group 2" exist
  When I open the manage groups dialog
  And I click "Group 2" in a "p .field" element
  And I enter "Some other name" in the text input
  Then I should see "Group 1" within the "#groups" block
  And I should not see "Group 2" within the "#groups" block
  And I should see "Some other name" within the "#groups" block

  When I open the manage groups dialog
  Then I should see "Group 1" within the "#groups" block
  And I should not see "Group 2" within the "#groups" block
  And I should see "Some other name" within the "#groups" block


Scenario: Add a group
  Given the groups "Group 1, Group 2" exist
  When I open the manage groups dialog
  And I click "Add group"
  And I enter "New group" in the text input
  Then I should see "New group" within the "#groups" block
  
  When I open the manage groups dialog
  Then I should see "Group 1" within the "#groups" block
  Then I should see "Group 2" within the "#groups" block
  Then I should see "New group" within the "#groups" block


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
  Then I should see "Group A" within the ".has-groups" block
  And I should see "Group B" within the ".has-groups" block
  And I should see "Group C" within the ".has-groups" block
  
  When I click the element ".add" within the ".groups" block
  Then I should see "Group D" within the ".groups .filtered-list" block
  And I should see "Group E" within the ".groups .filtered-list" block
  And I should not see "Group A" within the ".groups .filtered-list" block
  And I should not see "Group B" within the ".groups .filtered-list" block
  And I should not see "Group C" within the ".groups .filtered-list" block

  When I enter "e" in the text input
  Then I should not see "Group D" within the ".groups .filtered-list" block
  And I should see "Group E" within the ".groups .filtered-list" block

  When I click "Group E" within the ".groups .filtered-list" block
  Then I should not see "Group E" within the ".groups .filtered-list" block
  Then I should see "Group E" within the ".has-groups" block

  When I go to the page for that profile
  Then I should see "Group A" within the ".has-groups" block
  And I should see "Group B" within the ".has-groups" block
  And I should see "Group C" within the ".has-groups" block
  And I should see "Group E" within the ".has-groups" block

  When I click the element ".add" within the ".groups" block
  Then I should see "Group D" within the ".groups .filtered-list" block
  And I should not see "Group E" within the ".groups .filtered-list" block

  When I click "Remove" in a ".has-groups li" element containing "Group B" as text
  And I should not see "Group B" within the ".has-groups" block
  Then I should see "Group A" within the ".has-groups" block
  And I should see "Group C" within the ".has-groups" block
  And I should see "Group E" within the ".has-groups" block
  And I should see "Group D" within the ".groups .filtered-list" block
  And I should see "Group B" within the ".groups .filtered-list" block

  When I go to the page for that profile
  Then I should not see "Group B" within the ".has-groups" block
  Then I should see "Group A" within the ".has-groups" block
  And I should see "Group C" within the ".has-groups" block
  And I should see "Group E" within the ".has-groups" block

  When I click the element ".add" within the ".groups" block
  Then I should see "Group D" within the ".groups .filtered-list" block
  And I should see "Group B" within the ".groups .filtered-list" block