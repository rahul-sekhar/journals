@current
Feature: View individual student observations on a post and add them to a post

Teacher posts should allow the editing of student observations. Student and guardian posts should not n Iallow or show student observations.

Background:
  Given I have logged in as the teacher Rahul


Scenario: View a post without student observations
  Given a post about an ice cream factory visit with extended information exists
  When I am on the page for that post
  And I look at the post "Ice cream factory visit"
  Then I should not see "Sahana" in the posts student-observations
  And I should not see "Ansh" in the posts student-observations


Scenario: View student observations for a post
  Given a post about an ice cream factory visit with student observations exists
  When I am on the page for that post
  And I look at the post "Ice cream factory visit"
  Then I should see "Some observations about Sahana" in the posts student-observations
  And I should not see "Ansh" in the posts student-observations


Scenario: Edit a post with tagged students and add student observations
  Given a post about an ice cream factory visit with extended information exists
  When I am on the edit page for that post
  Then I should see "Ansh" in the student observation buttons
  And I should see "Sahana" in the student observation buttons
  When I fill in the observation for "Ansh" with "Ansh is a good chap"
  And I fill in the observation for "Sahana" with "Sahana is a nice girl"
  And I click "Save post"

  Then I should see the post "Ice cream factory visit"
  When I look at the post "Ice cream factory visit"
  Then I should see "Ansh is a good chap" in the posts student-observations
  And I should see "Sahana is a nice girl" in the posts student-observations


Scenario: Edit a post with an existing student observation and remove it
  Given a post about an ice cream factory visit with student observations exists
  And I am on the edit page for that post
  When I fill in the observation for "Sahana" with ""
  And I click "Save post"

  Then I should see the post "Ice cream factory visit"
  When I look at the post "Ice cream factory visit"
  Then I should not see "Sahana" in the posts student-observations
  And I should not see "Ansh" in the posts student-observations


Scenario: Remove one observation and add a different one
  Given a post about an ice cream factory visit with student observations exists
  And I am on the edit page for that post
  When I fill in the observation for "Sahana" with ""
  When I fill in the observation for "Ansh" with "New observation"
  And I click "Save post"

  Then I should see the post "Ice cream factory visit"
  When I look at the post "Ice cream factory visit"
  Then I should not see "Sahana" in the posts student-observations
  And I should see "Ansh" in the posts student-observations
  And I should see "New observation" in the posts student-observations


Scenario: Remove a student tag and hence the student observation
  Given a post about an ice cream factory visit with student observations exists
  And I am on the edit page for that post
  When I fill in the observation for "Ansh" with "Some observation"
  And I untag the student "Sahana" in the post
  And I untag the student "Ansh" in the post
  And I click "Save post"

  Then I should see the post "Ice cream factory visit"
  When I look at the post "Ice cream factory visit"
  Then I should not see "Sahana" in the posts student-observations
  And I should not see "Ansh" in the posts student-observations


Scenario: Edit a student post
  Given a student post about an ice cream factory visit with extended information exists
  When I am on the edit page for that post
  Then I should not see "student observations"


Scenario: Edit a guardian post
  Given a guardian post about an ice cream factory visit with extended information exists
  When I am on the edit page for that post
  Then I should not see "student observations"