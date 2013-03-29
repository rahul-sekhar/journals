Feature: Add comments to a post

Background:
  Given some base students and teachers exist
  And a post about an ice cream factory visit exists
  And I have logged in as the teacher Rahul

Scenario: Add a comment to a post
  When I am on the page for that post
  And I look at the post "Ice cream factory visit"
  Then I should see "No comments" in it
  And I click "Read more" in it
  And I fill in "Enter comment" with "Test comment" in it
  And I click "Comment" in it

  Then I should see "Test comment" in it
  And I should see "Posted by Rahul Sekhar" in it

  When I click "Read less" in it
  Then I should see "1 comment" in it