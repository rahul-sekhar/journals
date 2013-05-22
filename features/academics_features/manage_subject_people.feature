Feature: Manage subject teachers and students

Background:
  Given I have logged in as the teacher Rahul
  And the subject "Math" exists with teachers and students
  And I am on the subjects page
  And I manage people for the subject "Math"


Scenario: View the subject people dialog
  When I look at the dialog
  Then I should see "Math" in it
  And I should see "John" in its teachers
  And I should see "William" in its teachers
  And I should not see "Bruce" in its teachers


Scenario: Remove a teacher
  When I look at the dialog
  And I remove the teacher "William" from it
  Then I should not see "William" in its teachers

  When I go to the subjects page
  And I manage people for the subject "Math"
  And I look at the dialog
  Then I should not see "William" in its teachers
  And I should see "John" in its teachers
  And I should not see "Bruce" in its teachers

@current
Scenario: Add a teacher
  When I look at the dialog
  When I open its add teacher list
  Then I should see "bruce" in the list
  And I should not see "john" in the list
  And I should not see "william" in the list

  When I click "Bruce" in the list
  Then I should see "Bruce" in its teachers
  When I open its add teacher list
  Then I should not see "bruce" in the list

  When I go to the subjects page
  And I manage people for the subject "Math"
  And I look at the dialog
  Then I should see "William" in its teachers
  And I should see "John" in its teachers
  And I should see "Bruce" in its teachers
  When I open its add teacher list
  Then I should not see "bruce" in the list