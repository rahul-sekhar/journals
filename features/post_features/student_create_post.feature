Feature: Create a post as a student

Students should be allowed to create posts but not set permissions, and cannot remove their own tag from the post

Background:
  Given some base students and teachers exist
  And I have logged in as a student "Rahul Sekhar"
  And I am on the new post page

Scenario: Create a minimal post with a title, content and tags
  When I fill in "Title" with "Test Post"
  And I fill in "Content" with "<p>Some <em>HTML</em> content</p>"
  And I fill in "Tags" with "Test posts, Minimal"
  And I click "Create post"
  Then a minimal test post should exist
  And I should be on the posts page
  And I should see "Test Post"

Scenario: Add student and teacher tags to a post, without being able to remove own tag
  When I fill in "Title" with "Tagged Student Post"
  And I unselect "Rahul Sekhar" from "Student tags"
  And I select "Ansh Something" from "Student tags"
  And I select "Angela Jain" from "Teacher tags"
  And I click "Create post"
  Then a student post with student and teacher tags should exist

Scenario: Set post permissions
  Then I should not see "Permissions"
