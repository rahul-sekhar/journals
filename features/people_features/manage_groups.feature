@angular
Feature: Manage groups and their students

Teachers can view and manage the groups for all students.

Background:
  Given I have logged in as the teacher Rahul


Scenario: View the groups dialog with no groups
  When I go to the people page
  And I open the manage groups dialog
  Then I should see "Manage groups" in it
  And I should see "There are no groups yet" in it


Scenario: View the groups page when there are groups
  Given the groups "Group 1, Group 2" exist
  When I go to the people page
  And I open the manage groups dialog
  Then I should see "Group 1" in it
  And I should see "Group 2" in it


Scenario: Delete a group
  Given the groups "Group 1, Group 2" exist
  When I go to the people page
  And I open the manage groups dialog

  When I delete the group "Group 1"
  Then I should not see "Group 1" in it
  And I should see "Group 2" in it

  When I go to the people page
  And I open the manage groups dialog
  Then I should not see "Group 1" in it
  And I should see "Group 2" in it


Scenario: Edit a group
  Given the groups "Group 1, Group 2" exist
  When I go to the people page
  And I open the manage groups dialog

  When I change the group "Group 2" to "Changed"
  Then I should not see "Group 2" in it
  And I should see "Changed" in it

  When I go to the people page
  And I open the manage groups dialog
  Then I should see "Group 1" in it
  Then I should not see "Group 2" in it
  And I should see "Changed" in it


Scenario: Add a group
  Given the groups "Group 1, Group 2" exist
  And I open the manage groups dialog

  When I add the group "New group"
  Then I should see "New group" in it

  When I go to the people page
  And I open the manage groups dialog
  Then I should see "Group 1" in it
  Then I should see "Group 2" in it
  Then I should see "New group" in it


Scenario: Add and then delete a group
  Given the groups "Group 1, Group 2" exist
  When I go to the people page
  And I open the manage groups dialog

  When I add the group "New group"
  Then I should see "New group" in it
  When I delete the group "New group"
  Then I should not see "New group" in it

  When I go to the people page
  And I open the manage groups dialog
  Then I should not see "New group" in it


Scenario: View a student with no groups
  Given a student Parvathy exists
  And I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  Then I should see "Groups" in it
  And I should see "None" in its groups


Scenario: View a student with groups, add and remove groups
  Given a student Parvathy exists
  And that student belongs to the groups "Group A, Group B, Group C"
  And the groups "Group D, Group E" exist
  And I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"

  Then I should see "Group A" in its groups
  And I should see "Group B" in its groups
  And I should see "Group C" in its groups

  When I open its add group list
  Then I should see "Group D" in the list
  And I should see "Group E" in the list
  And I should not see "Group A" in the list
  And I should not see "Group B" in the list
  And I should not see "Group C" in the list
  When I enter "e" in its add group list
  Then I should not see "Group D" in the list
  And I should see "Group E" in the list

  When I click "Group E" in the list
  Then I should not see "Group E" in the list
  Then I should see "Group E" in its groups

  When I remove the group "Group B" from it
  Then I should not see "Group B" in its groups
  And I should see "Group A" in its groups
  And I should see "Group C" in its groups
  And I should see "Group E" in its groups
  When I open its add group list
  Then I should see "Group D" in the list
  And I should see "Group B" in the list

  When I go to the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  Then I should not see "Group B" in its groups
  Then I should see "Group A" in its groups
  And I should see "Group C" in its groups
  And I should see "Group E" in its groups

  When I open its add group list
  Then I should see "Group D" in the list
  And I should see "Group B" in the list


Scenario: Manage a group and view the reflected changes in each student
  Given a student Parvathy exists
  And that student belongs to the groups "Group A, Group B, Group C"
  And the groups "Group D, Group E" exist
  And I am on the students page
  And I look at the profile for "Parvathy Manjunath"

  Then I should see "Group A" in its groups
  And I should see "Group B" in its groups
  And I should see "Group C" in its groups

  When I open the manage groups dialog
  And I change the group "Group B" to "Changed name"
  And I look at the profile for "Parvathy Manjunath"
  Then I should not see "Group B" in its groups
  And I should see "Changed name" in its groups

  When I look at the dialog
  And I delete the group "Changed name"
  And I look at the profile for "Parvathy Manjunath"
  Then I should not see "Changed name" in its groups
