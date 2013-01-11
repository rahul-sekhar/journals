Feature: Create a post as a guardian

Guardians should be able to create posts and set only student permissions on the post. They should have all their students tagged initially, and must save the post with at least one tagged.

Background:
  Given some base students and teachers exist
  And I have logged in as a guardian "Rahul Sekhar" to the student "Roly Sekhar"
  And I am on the new post page

Scenario: Create a minimal post with a title, content and tags
  When I fill in "Title" with "Test Post"
  And I fill in "Content" with "<p>Some <em>HTML</em> content</p>"
  And I fill in "Tags" with "Test posts, Minimal"
  And I click "Create post"
  Then a minimal test post should exist
  And I should be on the posts page
  And I should see "Test Post"

Scenario: Add student and teacher tags to a post
  When I fill in "Title" with "Tagged Guardian Post"
  And I select "Ansh" from "Student tags"
  And I select "Angela" from "Teacher tags"
  And I click "Create post"
  Then a guardian post with student and teacher tags should exist

Scenario: Create a post without own students tag
  When I fill in "Title" with "Tagged Guardian Post"
  And I select "Ansh" from "Student tags"
  And I unselect "Roly" from "Student tags"
  And I click "Create post"
  Then I should be on the new post page
  And I should see "You must tag at least one of your own students"

Scenario: Set post permissions
  Then I should not see "Guardians"
  And the checkbox "Students" should be unchecked
  When I fill in "Title" with "Guardian Permissions Post"
  And I check the checkbox "Students"
  And I click "Create post"
  Then a guardian post with permissions should exist

Scenario: Create a post as a guardian with multiple students
  Given the guardian "Rahul Sekhar" has a student "Lucky Sekhar"
  When I am on the new post page
  Then "Student tags" should have "Roly, Lucky" selected
  When I fill in "Title" with "Guardian Post with Lucky"
  And I unselect "Roly" from "Student tags"
  And I click "Create post"
  Then a guardian post with lucky should exist

Scenario: Untag all students as a guardian with multiple students
  Given the guardian "Rahul Sekhar" has a student "Lucky Sekhar"
  When I am on the new post page
  And I fill in "Title" with "Guardian Post with Lucky"
  And I unselect "Roly" from "Student tags"
  And I unselect "Lucky" from "Student tags"
  And I click "Create post"
  Then I should be on the new post page
  And I should see "You must tag at least one of your own students"