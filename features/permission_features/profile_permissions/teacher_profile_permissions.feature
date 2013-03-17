@angular
Feature: Profile permissions for a teacher

As a teacher, I can view, edit and administrate any profile

Background:
  Given I have logged in as the teacher Rahul


Scenario: Manage a teacher profile
  Given a teacher "Shalini Sekhar" exists
  And the students Roly Sekhar, Lucky Sekhar, Jumble Dog exist
  And that teacher has the mentees Roly

  When I am on the page for that profile
  And I look at the profile for "Shalini Sekhar"

  Then I should be able to change the field "Email"
  And I should be able to change the name
  And I should see the add-field menu in it

  And I should see the manage menu in it

  When I open the mentees menu
  Then I should see its add mentee list


Scenario: Manage a student profile
  Given a student Parvathy exists
  And the teachers Angela Jain, Shalini Sekhar exist
  And that student belongs to the mentors Angela
  And the groups "Some Group, Other Group" exist
  And that student belongs to the groups "Some Group"

  When I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"

  Then I should be able to change the field "Email"
  And I should be able to change the name
  And I should see the add-field menu in it

  And I should see the manage menu in it

  When I open the mentors menu
  Then I should see its add mentor list

  When I open the groups menu
  Then I should see its add group list

  And I should see "ADD GUARDIAN" in it


Scenario: Manage a guardian
  Given a student Parvathy exists
  And a guardian Poonam exists for that student

  When I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  And I look at the guardian "Poonam Jain"

  Then I should be able to change the field "Email"
  And I should be able to change the guardian name
  And I should see the add-field menu in it

  And I should see the manage menu in it


Scenario: Create users
  When I am on the people page
  Then I should see the add menu
