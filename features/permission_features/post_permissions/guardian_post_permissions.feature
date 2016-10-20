Feature: Post permissions for a guardian

As a guardian, I can view and edit my own posts and view posts that I am tagged in.

Background:
  Given I have logged in as the guardian Rahul
  And I have a student "Lucky Sekhar"


Scenario: A post created by me
  Given a post titled "A post" created by me exists
  When I am on the page for that post
  Then I should see the post "A post"
  When I look at the post "A post"
  Then I should see "Edit post"
  When I am on the edit page for that post
  And "Title" should be filled in with "A post"
  And I click "Save post"
  Then I should not see an error

Scenario: A post created by someone else that I am not tagged in, that is visible to guardians
  Given a post titled "A post" created by a teacher exists
  And that post is visible to guardians
  When I go to the page for that post
  Then I should see "Post not found"
  When I go to the edit page for that post
  Then I should see "Post not found"

Scenario: A post created by someone else that one of my students is tagged in, that is visible to guardians
  Given a post titled "A post" created by a teacher exists
  And that post has the student "Lucky" tagged
  And that post is visible to guardians
  When I am on the page for that post
  Then I should see the post "A post"
  When I look at the post "A post"
  Then I should not see "Edit post"

  When I go to the edit page for that post
  And I click "Save post"
  Then I should see an error

Scenario: A post created by someone else that one of my students is tagged in, that is invisible to guardians
  Given a post titled "A post" created by a teacher exists
  And that post has the student "Lucky" tagged
  And that post is not visible to guardians
  When I go to the page for that post
  Then I should see "Post not found"
  When I go to the edit page for that post
  Then I should see "Post not found"


Scenario: View posts page
  Given a student "Jumble Dog" exists
  And a post titled "My post" created by me exists
  And a post titled "Untagged post" created by a teacher exists
  And that post is visible to guardians
  And a post titled "Other tagged post" created by a teacher exists
  And that post has the student "Jumble" tagged
  And that post is visible to guardians
  And a post titled "Tagged post 1" created by a teacher exists
  And that post has the student "Lucky" tagged
  And that post is visible to guardians
  And a post titled "Tagged post 2" created by a teacher exists
  And that post has the student "Lucky" tagged
  And that post has the student "Roly" tagged
  And that post is visible to guardians
  And a post titled "Tagged post 3" created by a teacher exists
  And that post has the student "Roly" tagged
  And that post is visible to guardians
  And a post titled "Tagged invisible post 1" created by a teacher exists
  And that post has the student "Lucky" tagged
  And that post is not visible to guardians
  And a post titled "Tagged invisible post 2" created by a teacher exists
  And that post has the student "Roly" tagged
  And that post is not visible to guardians
  And a post titled "Tagged invisible post 3" created by a teacher exists
  And that post has the student "Roly" tagged
  And that post has the student "Lucky" tagged
  And that post is not visible to guardians

  When I am on the posts page
  Then I should see the post "My post"
  Then I should see the post "Tagged post 1"
  And I should see the post "Tagged post 2"
  And I should see the post "Tagged post 3"
  And I should not see the post "Untagged post"
  And I should not see the post "Other tagged post"
  And I should not see the post "Tagged invisible post 1"
  And I should not see the post "Tagged invisible post 2"
  And I should not see the post "Tagged invisible post 3"