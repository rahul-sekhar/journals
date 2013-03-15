@angular
Feature: Profile permissions for a student

As a student, I can view any profile and edit my own.

Background:
  Given I have logged in as the student Rahul


Scenario: View a teacher profile
  Given a teacher "Shalini Sekhar" exists
  And the students Lucky Sekhar, Jumble Dog exist
  And that teacher has the mentees Lucky

  When I am on the page for that profile
  And I look at the profile for "Shalini Sekhar"

  Then I should not be able to change the field "Email"
  And I should not be able to change the name
  And I should not see the add-field menu in it

  And I should not see the manage menu in it

  And I should not see "Remove" in its mentees
  And I should not see its add mentee list


Scenario: View a student profile
  Given a student Parvathy exists
  And the teachers Angela Jain, Shalini Sekhar exist
  And that student belongs to the mentors Angela
  And the groups "Some Group, Other Group" exist
  And that student belongs to the groups "Some Group"

  When I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"

  Then I should not be able to change the field "Email"
  And I should not be able to change the name
  And I should not see the add-field menu in it

  And I should not see the manage menu in it

  And I should not see "Remove" in its mentors
  And I should not see its add mentor list

  And I should not see "Remove" in its groups
  And I should not see its add group list

  And I should not see "ADD GUARDIAN" in it


Scenario: Edit my own profile
  Given the teachers Angela Jain, Shalini Sekhar exist
  And I belong to the mentors "Angela"
  And I have the guardian "Archana Sekhar"
  And the groups "Some Group, Other Group" exist
  And I belong to the groups "Some Group"

  When I am on the page for my profile
  And I look at the profile for "Rahul Sekhar"

  Then I should be able to change the first field "Email"
  And I should be able to change the name
  And I should see the add-field menu in it

  And I should not see the manage menu in it

  And I should not see "Remove" in its mentors
  And I should not see its add mentor list

  And I should not see "Remove" in its groups
  And I should not see its add group list

  And I should not see "ADD GUARDIAN" in it

  When I look at the guardian "Archana Sekhar"
  Then I should not be able to change the field "Email"
  And I should not be able to change the guardian name
  And I should not see the add-field menu in it
  And I should not see the manage menu in it



Scenario: View a guardian
  Given a student Parvathy exists
  And a guardian Poonam exists for that student

  When I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  And I look at the guardian "Poonam Jain"

  Then I should not be able to change the field "Email"
  And I should not be able to change the guardian name
  And I should not see the add-field menu in it
  And I should not see the manage menu in it


Scenario: Create users
  When I am on the people page
  Then I should not see the add menu