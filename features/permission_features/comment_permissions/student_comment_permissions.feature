Feature: Comment permissions for a student

As a student, I can view any comment and edit and delete my own comments

Background:
  Given I have logged in as a student "Rahul Sekhar"

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
  Then I should not see "Edit" within the ".comments" block
  And I should not see "Delete" within the ".comments" block
  And I should get a forbidden message when I go to the edit page for that comment