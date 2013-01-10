Feature: View mentees

A teacher can view their own mentees by going to the mentees page. Students and Guardians should not be able to access this page

Scenario: View mentees as a student
  When I have logged in as a student "Rahul Sekhar"
  Then I should get a page not found message when I go to the mentees page

Scenario: View mentees as a guardian
  When I have logged in as a guardian "Rahul Sekhar" to the student "Roly Sekhar"
  Then I should get a page not found message when I go to the mentees page

Scenario: View mentees as a teacher
  Given I have logged in as a teacher "Rahul Sekhar"
  And the students Roly, Lucky and Jumble exist
  And I have the mentees "Roly, Lucky"
  When I am on the mentees page
  Then I should see the heading "Roly Sekhar"
  And I should see the heading "Lucky Sekhar"
  And I should not see the heading "Jumble Sekhar"