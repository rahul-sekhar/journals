Feature: Comment permissions for a teacher

As a teacher, I can view, edit and delete any comment

Background:
  Given I have logged in as the teacher Rahul

Scenario: A comment created by me
  Given a post titled "A post" created by me exists
  And that post has a comment "Test comment" by me

  When I am on the page for that post
  And I look at the post "A post"
  When I look at the posts first comment
  Then I should see a edit link in the posts comments
  And I should see a delete link in the posts comments

Scenario: A comment created by someone else
  Given a post titled "A post" created by me exists
  And that post has a comment "Test comment" by a guardian

  When I am on the page for that post
  And I look at the post "A post"
  When I look at the posts first comment
  Then I should see a edit link in the posts comments
  And I should see a delete link in the posts comments