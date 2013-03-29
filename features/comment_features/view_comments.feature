Feature: View comments for a post with them

Background:
  Given some base students and teachers exist
  And a post about an ice cream factory visit exists
  And I have logged in as a teacher "Rahul Sekhar"

Scenario: View a post with no comments
  Given I am on the posts page
  Then I should see "Ice cream factory visit"
  And a ".comments" block should not be present

Scenario: View a post with comments
  Given that post has a comment "First comment" dated "25/10/2012" by the student "Ansh"
  And that post has a comment "Another comment" dated "28/11/2012" by the teacher "Aditya"
  And I am on the posts page
  Then I should see "Ice cream factory visit"
  And I should see "Comments"
  And a ".comments" block should be present
  And I should see "First comment"
  And I should see "Posted by Ansh Something on 25th October 2012"
  And I should see "Another comment"
  And I should see "Posted by Aditya Pandya on 28th November 2012"