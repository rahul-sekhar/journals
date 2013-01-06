Feature: Comment permissions for a teacher

As a teacher, I can view, edit and delete any comment

Background:
  Given I have logged in as a teacher "Rahul Sekhar"

Scenario: A comment created by me
  Given a post titled "A post" created by me exists
  And that post has a comment "Test comment", posted by me
  When I am on the page for that post
  And I click "Edit" within the ".comments" block
  Then I should be on the edit page for that comment
  And "Enter comment" should be filled in with "Test comment"

  When I am on the page for that post
  And I click "Delete" within the ".comments" block
  Then I should see "The comment has been deleted"

Scenario: A comment created by someone else
  Given a post titled "A post" created by me exists
  And that post has a comment "Test comment", posted by a guardian
  When I am on the page for that post
  And I click "Edit" within the ".comments" block
  Then I should be on the edit page for that comment
  And "Enter comment" should be filled in with "Test comment"

  When I am on the page for that post
  And I click "Delete" within the ".comments" block
  Then I should see "The comment has been deleted"