Feature: Post permissions for a guardian

As a guardian, I can view and edit my own posts and view posts that I am tagged in.

Background:
  Given I have logged in as a guardian "Rahul Sekhar" to the student "Roly Sekhar"

Scenario: A post created by me
  Given a post titled "A post" created by me exists
  When I am on the page for that post
  Then I should see "A post"
  And I should see "Edit post"
  When I am on the edit page for that post
  And "Title" should be filled in with "A post"

Scenario: A post created by someone else that I am not tagged in, that is visible to guardians
  Given a post titled "A post" created by a teacher exists
  And that post is visible to guardians
  Then I should get a forbidden message when I go to the page for that post
  And I should get a forbidden message when I go to the edit page for that post

Scenario: A post created by someone else that my student is tagged in, that is visible to guardians
  Given a post titled "A post" created by a teacher exists
  And that post has the student "Roly Sekhar" tagged
  And that post is visible to guardians
  When I am on the page for that post
  Then I should see "A post"
  And I should not see "Edit post"
  And I should get a forbidden message when I go to the edit page for that post

Scenario: A post created by someone else that my student is tagged in, that is invisible to guardians
  Given a post titled "A post" created by a teacher exists
  And that post has the student "Roly Sekhar" tagged
  And that post is not visible to guardians
  Then I should get a forbidden message when I go to the page for that post
  And I should get a forbidden message when I go to the edit page for that post