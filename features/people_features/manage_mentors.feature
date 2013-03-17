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
  And I should see "none" in its mentors


Scenario: View a student with mentors, add and remove mentors
  Given the teachers Angela Jain, Shalini Sekhar, Aditya Pandya, Sharad Jain exist
  And a student Parvathy exists
  And that student belongs to the mentors Angela, Sharad

  When I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  When I open the mentors menu
  Then I should see "angela" in its mentors
  And I should see "sharad" in its mentors

  When I open its add mentor list
  Then I should see "shalini" in the list
  And I should see "aditya" in the list
  And I should see "rahul" in the list
  And I should not see "angela" in the list
  And I should not see "sharad" in the list
  When I enter "i" in its add mentor list
  Then I should not see "rahul" in the list
  And I should see "shalini" in the list
  And I should see "aditya" in the list

  When I click "Aditya Pandya" in the list
  Then I should not see "aditya" in the list
  And I should see "aditya" in its mentors

  When I remove the mentor "angela jain" from it
  Then I should not see "angela" in its mentors
  And I should see "sharad" in its mentors
  And I should see "aditya" in its mentors
  When I open its add mentor list
  Then I should see "angela" in the list
  And I should see "shalini" in the list
  And I should see "rahul" in the list

  When I go to the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  And I open the mentors menu
  Then I should not see "angela" in its mentors
  And I should see "sharad" in its mentors
  And I should see "aditya" in its mentors

  When I open its add mentor list
  Then I should see "angela" in the list
  And I should see "shalini" in the list
  And I should see "rahul" in the list


Scenario: View a teacher with no mentees
  And a teacher Shalini exists
  And I am on the page for that profile
  When I look at the profile for "Shalini Sekhar"
  Then I should see "Mentee" in it
  And I should see "none" in its mentees


Scenario: View a teacher with mentees, add and remove mentees
  Given the students Roly Sekhar, Lucky Sekhar, Jumble Dog exist
  And a teacher Shalini exists
  And that teacher has the mentees Roly, Lucky

  When I am on the page for that profile
  And I look at the profile for "Shalini Sekhar"
  And I open the mentees menu
  Then I should see "roly" in its mentees
  And I should see "lucky" in its mentees

  When I open its add mentee list
  Then I should see "jumble" in the list
  And I should not see "roly" in the list
  And I should not see "lucky" in the list
  When I enter "x" in its add mentee list
  Then I should not see "jumble" in the list
  When I enter "jumble" in its add mentee list
  Then I should see "jumble" in the list

  When I click "Jumble" in the list
  Then I should not see "jumble" in the list
  And I should see "jumble" in its mentees

  When I remove the mentee "lucky sekhar" from it
  Then I should not see "lucky" in its mentees
  And I should see "roly" in its mentees
  And I should see "jumble" in its mentees
  When I open its add mentee list
  Then I should see "lucky" in the list

  When I go to the page for that profile
  And I look at the profile for "Shalini Sekhar"
  And I open the mentees menu
  Then I should not see "lucky" in its mentees
  And I should see "roly" in its mentees
  And I should see "jumble" in its mentees
  When I open its add mentee list
  Then I should see "lucky" in the list


Scenario: Changes in mentors show in associated mentees
  Given the students Roly Sekhar, Lucky Sekhar, Jumble Dog exist
  And a teacher Shalini exists
  And that teacher has the mentees Roly, Lucky

  When I am on the people page
  And I look at the profile for "Rahul Sekhar"
  And I open the mentees menu in it
  Then I should see "none" in its mentees

  When I look at the profile for "Roly Sekhar"
  And I open the mentors menu in it
  Then I should see "shalini" in its mentors
  When I open its add mentor list
  And I click "Rahul" in the list
  And I look at the profile for "Rahul Sekhar"
  And I open the mentees menu in it
  Then I should see "roly" in its mentees

  When I look at the profile for "Roly Sekhar"
  And I open the mentors menu in it
  When I remove the mentor "shalini sekhar" from it
  And I look at the profile for "Shalini Sekhar"
  Then I should not see "roly" in its mentees

  When I go to the people page
  And I look at the profile for "Shalini Sekhar"
  And I open the mentees menu in it
  Then I should not see "roly" in its mentees
  And I should see "lucky" in its mentees

  When I look at the profile for "Rahul Sekhar"
  And I open the mentees menu in it
  Then I should see "roly" in its mentees

  When I look at the profile for "Roly Sekhar"
  And I open the mentors menu in it
  Then I should not see "shalini" in its mentors
  And I should see "rahul" in its mentors


Scenario: Changes in mentees show in associated mentors
  Given the students Roly Sekhar, Lucky Sekhar, Jumble Dog exist
  And a teacher Shalini exists
  And that teacher has the mentees Roly, Lucky

  When I am on the people page
  When I look at the profile for "Lucky Sekhar"
  And I open the mentors menu in it
  Then I should see "shalini" in its mentors

  When I look at the profile for "Shalini Sekhar"
  And I open the mentees menu in it
  And I remove the mentee "lucky sekhar" from it
  And I look at the profile for "Lucky Sekhar"
  Then I should not see "shalini" in its mentors
  And I should see "none" in its mentors

  When I look at the profile for "Rahul Sekhar"
  And I open the mentees menu in it
  And I open its add mentee list
  And I click "Roly" in the list
  And I look at the profile for "Roly Sekhar"
  And I open the mentors menu in it
  Then I should see "rahul" in its mentors

  When I go to the people page
  And I look at the profile for "Shalini Sekhar"
  And I open the mentees menu in it
  Then I should see "roly" in its mentees
  And I should not see "lucky" in its mentees

  When I look at the profile for "Rahul Sekhar"
  And I open the mentees menu in it
  Then I should see "roly" in its mentees
  And I should not see "lucky" in its mentees

  When I look at the profile for "Roly Sekhar"
  And I open the mentors menu in it
  Then I should see "shalini" in its mentors
  And I should see "rahul" in its mentors

  When I look at the profile for "Lucky Sekhar"
  And I open the mentors menu in it
  Then I should see "none" in its mentors
