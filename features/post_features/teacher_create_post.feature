Feature: Create a post as a teacher

As a teacher I should be able to create a post so that I can add content to the site

Background:
  Given some base students and teachers exist
  And I have logged in as a teacher "Rahul Sekhar"
  And I am on the create post page

Scenario: Create a minimal post with a title, content and tags
  When I fill in "Title" with "Test Post"
  And I fill in "Content" with "<p>Some <em>HTML</em> content</p>"
  And I fill in "Tags" with "Test posts, Minimal"
  And I click "Create post"
  Then a minimal test post should exist
  And I should be on the posts page
  And I should see "Test Post"

Scenario: Create a post without a title
  When I fill in "Content" with "Content without a title"
  And I click "Create post"
  Then I should be on the create post page
  And I should see "Invalid post"
  And "Content" should be filled in with "Content without a title"

Scenario: Add student and teacher tags to a post
  When I fill in "Title" with "Tagged Post"
  And I select "Ansh Something" from "Student tags"
  And I select "Sahana Somethingelse" from "Student tags"
  And I select "Angela Jain" from "Teacher tags"
  And I click "Create post"
  Then a post with student and teacher tags should exist

Scenario: Set post permissions
  Then the checkbox "Guardians" should be unchecked
  And the checkbox "Students" should be unchecked
  When I fill in "Title" with "Permissions Post"
  And I check the checkbox "Guardians"
  And I click "Create post"
  Then a post with permissions should exist