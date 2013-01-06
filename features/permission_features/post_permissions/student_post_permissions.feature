Feature: Post permissions for a student

As a student, I can view and edit my own posts and view posts that I am tagged in.

Background:
  Given I have logged in as a student "Rahul Sekhar"

Scenario: A post created by me
  Given a post titled "A post" created by me exists
  When I am on the page for that post
  Then I should see "A post"
  And I should see "Edit post"
  When I am on the edit page for that post
  And "Title" should be filled in with "A post"

Scenario: A post created by someone else that I am not tagged in, that is visible to students
  Given a post titled "A post" created by a teacher exists
  And that post is visible to students
  Then I should get a forbidden message when I go to the page for that post
  And I should get a forbidden message when I go to the edit page for that post

Scenario: A post created by someone else that I am tagged in, that is visible to students
  Given a post titled "A post" created by a teacher exists
  And that post has the student "Rahul Sekhar" tagged
  And that post is visible to students
  When I am on the page for that post
  Then I should see "A post"
  And I should not see "Edit post"
  And I should get a forbidden message when I go to the edit page for that post

Scenario: A post created by someone else that I am tagged in, that is invisible to students
  Given a post titled "A post" created by a teacher exists
  And that post has the student "Rahul Sekhar" tagged
  And that post is not visible to students
  Then I should get a forbidden message when I go to the page for that post
  And I should get a forbidden message when I go to the edit page for that post