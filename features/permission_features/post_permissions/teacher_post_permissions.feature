Feature: Post permissions for a teacher

As a teacher, I can view and edit any post

Background:
  Given I have logged in as the teacher Rahul

Scenario: A post created by me
  Given a post titled "A post" created by me exists
  When I am on the page for that post
  Then I should see the post "A post"
  When I look at the post "A post"
  Then I should see "Edit post" in it
  When I am on the edit page for that post
  Then "Title" should be filled in with "A post"

Scenario: A post created by another teacher
  Given a post titled "A post" created by a teacher exists
  When I am on the page for that post
  Then I should see the post "A post"
  When I look at the post "A post"
  Then I should see "Edit post" in it
  When I am on the edit page for that post
  Then "Title" should be filled in with "A post"

Scenario: A post created by a student
  Given a post titled "A post" created by a student exists
  When I am on the page for that post
  Then I should see the post "A post"
  When I look at the post "A post"
  Then I should see "Edit post" in it
  When I am on the edit page for that post
  Then "Title" should be filled in with "A post"

Scenario: A post created by a guardian
  Given a post titled "A post" created by a guardian exists
  When I am on the page for that post
  Then I should see the post "A post"
  When I look at the post "A post"
  Then I should see "Edit post" in it
  When I am on the edit page for that post
  Then "Title" should be filled in with "A post"


Scenario: View posts page
  Given a post titled "My post" created by me exists
  And a post titled "Teacher post" created by a teacher exists
  And a post titled "Student post" created by a student exists
  And a post titled "Guardian post" created by a guardian exists

  When I am on the posts page
  Then I should see the post "My post"
  And I should see the post "Teacher post"
  And I should see the post "Student post"
  And I should see the post "Guardian post"