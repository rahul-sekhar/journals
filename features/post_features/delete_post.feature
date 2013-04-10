Feature: Delete a post

Scenario: Delete a post
  Given a post about an ice cream factory visit exists
  And I have logged in as the teacher Rahul

  When I go to the posts page
  Then I should see the post "Ice cream factory visit"

  And I am on the edit page for that post
  When I click "Delete post"
  Then I should see "Post deleted"

  When I go to the posts page
  Then I should not see the post "Ice cream factory visit"