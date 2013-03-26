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
  Given the groups "group 1, group 2" exist
  When I go to the people page
  And I open the manage groups dialog
  Then I should see "group 1" in it
  And I should see "group 2" in it


Scenario: Delete a group
  Given the groups "group 1, group 2" exist
  When I go to the people page
  And I open the manage groups dialog

  When I delete the group "group 1"
  Then I should not see "group 1" in it
  And I should see "group 2" in it

  When I go to the people page
  And I open the manage groups dialog
  Then I should not see "group 1" in it
  And I should see "group 2" in it


Scenario: Edit a group
  Given the groups "group 1, group 2" exist
  When I go to the people page
  And I open the manage groups dialog

  When I change the group "group 2" to "Changed"
  Then I should not see "group 2" in it
  And I should see "Changed" in it

  When I go to the people page
  And I open the manage groups dialog
  Then I should see "group 1" in it
  Then I should not see "group 2" in it
  And I should see "Changed" in it


Scenario: Add a group
  Given the groups "group 1, group 2" exist
  When I am on the people page
  And I open the manage groups dialog

  When I add the group "New group"
  Then I should see "New group" in it

  When I go to the people page
  And I open the manage groups dialog
  Then I should see "group 1" in it
  Then I should see "group 2" in it
  Then I should see "New group" in it


Scenario: Add and then delete a group
  Given the groups "group 1, group 2" exist
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
  When I open the groups menu
  Then I should see "none" in its groups


Scenario: View a student with groups, add and remove groups
  Given a student Parvathy exists
  And that student belongs to the groups "group a, group b, group c"
  And the groups "group d, group e" exist
  And I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"

  When I open the groups menu
  Then I should see "group a" in its groups
  And I should see "group b" in its groups
  And I should see "group c" in its groups

  When I open its add group list
  Then I should see "group d" in the list
  And I should see "group e" in the list
  And I should not see "group a" in the list
  And I should not see "group b" in the list
  And I should not see "group c" in the list
  When I enter "e" in its add group list
  Then I should not see "group d" in the list
  And I should see "group e" in the list

  When I click "group e" in the list
  Then I should not see "group e" in the list
  Then I should see "group e" in its groups

  When I remove the group "group b" from it
  Then I should not see "group b" in its groups
  And I should see "group a" in its groups
  And I should see "group c" in its groups
  And I should see "group e" in its groups
  When I open its add group list
  Then I should see "group d" in the list
  And I should see "group b" in the list

  When I go to the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  When I open the groups menu
  Then I should not see "group b" in its groups
  Then I should see "group a" in its groups
  And I should see "group c" in its groups
  And I should see "group e" in its groups

  When I open its add group list
  Then I should see "group d" in the list
  And I should see "group b" in the list


Scenario: Manage a group and view the reflected changes in each student
  Given a student Parvathy exists
  And that student belongs to the groups "group a, group b, group c"
  And the groups "group d, group e" exist
  And I am on the students page
  And I look at the profile for "Parvathy Manjunath"

  When I open the groups menu
  Then I should see "group a" in its groups
  And I should see "group b" in its groups
  And I should see "group c" in its groups

  When I open the manage groups dialog
  And I change the group "group b" to "changed name"
  And I close the dialog
  And I look at the profile for "Parvathy Manjunath"
  When I open the groups menu
  Then I should not see "group b" in its groups
  And I should see "changed name" in its groups

  When I open the manage groups dialog
  And I delete the group "changed name"
  And I close the dialog
  And I look at the profile for "Parvathy Manjunath"
  And I open the groups menu
  Then I should not see "changed name" in its groups
