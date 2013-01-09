Feature: Add comments to a post

Background:
  Given some base students and teachers exist
  And a post about an ice cream factory visit exists
  And I have logged in as a teacher "Rahul Sekhar"

Scenario: Add a comment to a post
  When I am on the page for that post
  And I fill in "Enter comment" with "Test comment"
  And I click "Comment"
  Then I should see "Comments"
  And I should see "Test comment"
  And I should see "Posted by Rahul Sekhar"
  And I should be on the page for that post