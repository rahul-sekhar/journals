Feature: View comments for a post with them

Background:
  Given some base students and teachers exist
  And a post about an ice cream factory visit exists
  And I have logged in as the teacher Rahul

Scenario: View a post with no comments
  Given I am on the posts page
  Then I should see "Ice cream factory visit"
  And I should see "No comments"

Scenario: View a post with comments
  Given that post has a comment "First comment" dated "25/10/2012" by the student "Ansh"
  And that post has a comment "Another comment" dated "28/11/2012" by the teacher "Aditya"
  And I am on the posts page
  Then I should see the post "Ice cream factory visit"
  When I look at the post "Ice cream factory visit"
  And I should see "2 comments" in it
  And I should not see "First comment" in it
  And I should not see "Another Comment" in it

  When I click "Read more" in it
  Then I should see "First comment" in it
  And I should see "Posted by Ansh Prasad on 25th October 2012" in it
  And I should see "Another comment" in it
  And I should see "Posted by Aditya Pandya on 28th November 2012" in it