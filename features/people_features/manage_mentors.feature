@angular
Feature: Manage mentors and mentees

Teachers can view and manage mentors and mentees

Background:
  Given I have logged in as the teacher Rahul


Scenario: View a student with no mentors
  Given a student Parvathy exists
  And I am on the page for that profile
  When I look at the profile for "Parvathy Manjunath"
  Then I should see "Mentor" in it
  And I should see "None" in its mentors


Scenario: View a student with mentors, add and remove mentors
  Given the teachers Angela Jain, Shalini Sekhar, Aditya Pandya, Sharad Jain exist
  And a student Parvathy exists
  And that student belongs to the mentors Angela, Sharad
  
  When I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  Then I should see "Angela" in its mentors
  And I should see "Sharad" in its mentors

  When I open its add mentor list
  Then I should see "Shalini" in the list
  And I should see "Aditya" in the list
  And I should see "Rahul" in the list
  And I should not see "Angela" in the list
  And I should not see "Sharad" in the list
  When I enter "i" in its add mentor list
  Then I should not see "Rahul" in the list
  And I should see "Shalini" in the list
  And I should see "Aditya" in the list

  When I click "Aditya" in the list
  Then I should not see "Aditya" in the list
  And I should see "Aditya" in its mentors
  
  When I remove the mentor "Angela Jain" from it
  Then I should not see "Angela" in its mentors
  And I should see "Sharad" in its mentors
  And I should see "Aditya" in its mentors
  When I open its add mentor list
  Then I should see "Angela" in the list
  And I should see "Shalini" in the list
  And I should see "Rahul" in the list

  When I go to the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  Then I should not see "Angela" in its mentors
  And I should see "Sharad" in its mentors
  And I should see "Aditya" in its mentors

  When I open its add mentor list
  Then I should see "Angela" in the list
  And I should see "Shalini" in the list
  And I should see "Rahul" in the list


Scenario: View a teacher with no mentees
  And a teacher Shalini exists
  And I am on the page for that profile
  When I look at the profile for "Shalini Sekhar"
  Then I should see "Mentee" in it
  And I should see "None" in its mentees


Scenario: View a teacher with mentees, add and remove mentees
  Given the students Roly Sekhar, Lucky Sekhar, Jumble Dog exist
  And a teacher Shalini exists
  And that teacher has the mentees Roly, Lucky
  
  When I am on the page for that profile
  And I look at the profile for "Shalini Sekhar"
  Then I should see "Roly" in its mentees
  And I should see "Lucky" in its mentees

  When I open its add mentee list
  Then I should see "Jumble" in the list
  And I should not see "Roly" in the list
  And I should not see "Lucky" in the list
  When I enter "x" in its add mentee list
  Then I should not see "Jumble" in the list
  When I enter "jumble" in its add mentee list
  Then I should see "Jumble" in the list

  When I click "Jumble" in the list
  Then I should not see "Jumble" in the list
  And I should see "Jumble" in its mentees
  
  When I remove the mentee "Lucky Sekhar" from it
  Then I should not see "Lucky" in its mentees
  And I should see "Roly" in its mentees
  And I should see "Jumble" in its mentees
  When I open its add mentee list
  Then I should see "Lucky" in the list

  When I go to the page for that profile
  And I look at the profile for "Shalini Sekhar"
  Then I should not see "Lucky" in its mentees
  And I should see "Roly" in its mentees
  And I should see "Jumble" in its mentees
  When I open its add mentee list
  Then I should see "Lucky" in the list