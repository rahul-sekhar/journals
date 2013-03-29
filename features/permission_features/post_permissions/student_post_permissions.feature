@angular
Feature: Post permissions for a student

As a student, I can view and edit my own posts and view posts that I am tagged in.

Background:
  Given I have logged in as the student Rahul

Scenario: A post created by me
  Given a post titled "A post" created by me exists
  When I am on the page for that post
  Then I should see the post "A post"
  When I look at the post "A post"
  And I should see "Edit post"
  When I am on the edit page for that post
  And "Title" should be filled in with "A post"

Scenario: A post created by someone else that I am not tagged in, that is visible to students
  Given a post titled "A post" created by a teacher exists
  And that post is visible to students
  When I go to the page for that post
  Then I should see "Post not found"
  When I go to the edit page for that post
  Then I should see "Post not found"

Scenario: A post created by someone else that I am tagged in, that is visible to students
  Given a post titled "A post" created by a teacher exists
  And that post has the student "Rahul" tagged
  And that post is visible to students
  When I am on the page for that post
  Then I should see the post "A post"
  When I look at the post "A post"
  Then I should not see "Edit post"

  When I go to the edit page for that post
  And I click "Save post"
  Then I should see "An error occurred"

Scenario: A post created by someone else that I am tagged in, that is invisible to students
  Given a post titled "A post" created by a teacher exists
  And that post has the student "Rahul" tagged
  And that post is not visible to students
  When I go to the page for that post
  Then I should see "Post not found"
  When I go to the edit page for that post
  Then I should see "Post not found"