Feature: Create a post as a guardian

As a teacher I should be able to create a post so that I can add content to the site

Background:
  Given some base students and teachers exist
  And I have logged in as a guardian "Rahul Sekhar" to the student "Roly Sekhar"
  And I am on the create post page

Scenario: Create a minimal post with a title, content and tags
  When I fill in "Title" with "Test Post"
  And I fill in "Content" with "<p>Some <em>HTML</em> content</p>"
  And I fill in "Tags" with "Test posts, Minimal"
  And I click "Create post"
  Then a minimal test post should exist
  And I should be on the posts page
  And I should see "Test Post"

Scenario: Add student and teacher tags to a post, without being able to remove own tag
  When I fill in "Title" with "Tagged Guardian Post"
  And I unselect "Roly" from "Student tags"
  And I select "Ansh" from "Student tags"
  And I select "Angela" from "Teacher tags"
  And I click "Create post"
  Then a guardian post with student and teacher tags should exist

Scenario: Set post permissions
  Then I should not see "Guardians"
  And the checkbox "Students" should be unchecked
  When I fill in "Title" with "Guardian Permissions Post"
  And I check the checkbox "Students"
  And I click "Create post"
  Then a guardian post with permissions should exist
