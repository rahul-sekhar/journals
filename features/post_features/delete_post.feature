Feature: Delete a post

Scenario: Delete a post
  Given a post about an ice cream factory visit exists
  And I have logged in as a teacher "Rahul Sekhar"
  And I am on the edit page for that post
  When I click "Delete post"
  Then that post should be destroyed
  And I should be on the posts page
  And I should see "The post has been deleted"