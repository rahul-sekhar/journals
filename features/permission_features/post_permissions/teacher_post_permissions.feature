Feature: Post permissions for a teacher

As a teacher, I can view and edit any post

Background:
  Given I have logged in as a teacher "Rahul Sekhar"

Scenario: A post created by me
  Given a post titled "A post" created by me exists
  When I am on the page for that post
  Then I should see "A post"
  And I should see "Edit post"
  When I am on the edit page for that post
  And "Title" should be filled in with "A post"

Scenario: A post created by another teacher
  Given a post titled "A post" created by a teacher exists
  When I am on the page for that post
  Then I should see "A post"
  And I should see "Edit post"
  When I am on the edit page for that post
  And "Title" should be filled in with "A post"

Scenario: A post created by a student
  Given a post titled "A post" created by a student exists
  When I am on the page for that post
  Then I should see "A post"
  And I should see "Edit post"
  When I am on the edit page for that post
  And "Title" should be filled in with "A post"

Scenario: A post created by a guardian
  Given a post titled "A post" created by a guardian exists
  When I am on the page for that post
  Then I should see "A post"
  And I should see "Edit post"
  When I am on the edit page for that post
  And "Title" should be filled in with "A post"