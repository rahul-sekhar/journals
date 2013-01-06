@current
Feature: View individual student observations on a post and add them to a post

Teacher posts should allow the editing of student observations. Student and guardian posts should not allow or show student observations.

Background:
  Given I have logged in as a teacher "Rahul Sekhar"

Scenario: View a post without student observations
  Given a post about an ice cream factory visit with extended information exists
  When I am on the page for that post
  Then a ".student-observations" block should not be present

Scenario: View student observations for a post
  Given a post about an ice cream factory visit with student observations exists
  When I am on the page for that post
  Then I should see "Some observations about Sahana" within the ".student-observations" block
  And I should not see "Ansh" within the ".student-observations" block

Scenario: Edit a post with tagged students and add student observations
  Given a post about an ice cream factory visit with extended information exists
  When I am on the edit page for that post
  Then I should see "Ansh" within the ".student-observations" block
  And I should see "Sahana" within the ".student-observations" block
  When I fill in "Observations for Ansh" with "Ansh is a good chap"
  And I fill in "Observations for Sahana" with "Sahana is a nice girl"
  And I click "Save post"
  Then I should be on the page for that post
  And I should see "Ansh is a good chap"
  And I should see "Sahana is a nice girl"

Scenario: Edit a post with an existing student observation and remove it
  Given a post about an ice cream factory visit with student observations exists
  And I am on the edit page for that post
  When I fill in "Observations for Sahana" with ""
  And I click "Save post"
  Then I should be on the page for that post
  And a ".student-observations" block should not be present

Scenario: Edit a post with an existing student observation and change it
  Given a post about an ice cream factory visit with student observations exists
  And I am on the edit page for that post
  When I fill in "Observations for Sahana" with "Different observation"
  And I click "Save post"
  Then I should be on the page for that post
  And I should see "Different observation" within the ".student-observations" block

Scenario: Remove one observation and add a different one
  Given a post about an ice cream factory visit with student observations exists
  And I am on the edit page for that post
  When I fill in "Observations for Sahana" with ""
  When I fill in "Observations for Ansh" with "New observation"
  And I click "Save post"
  Then I should be on the page for that post
  And I should not see "Sahana" within the ".student-observations" block
  And I should see "Ansh" within the ".student-observations" block
  And I should see "New observation" within the ".student-observations" block

Scenario: Remove a student tag and hence the student observation
  Given a post about an ice cream factory visit with student observations exists
  And I am on the edit page for that post
  When I fill in "Observations for Ansh" with "Some observation"
  And I unselect "Sahana Somethingelse" from "Student tags"
  And I unselect "Ansh Something" from "Student tags"
  And I click "Save post"
  Then I should be on the page for that post
  And a ".student-observations" block should not be present

Scenario: Edit a student post
  Given a student post about an ice cream factory visit with extended information exists
  When I am on the edit page for that post
  Then a ".student-observations" block should not be present

Scenario: Edit a guardian post
  Given a guardian post about an ice cream factory visit with extended information exists
  When I am on the edit page for that post
  Then a ".student-observations" block should not be present