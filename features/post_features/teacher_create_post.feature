@angular
Feature: Create a post as a teacher

As a teacher I should be able to create a post so that I can add content to the site

Background:
  Given some base students and teachers exist
  And I have logged in as the teacher Rahul
  And I am on the new post page


Scenario: Create a minimal post with a title, content and tags
  When I fill in "Title" with "Test Post"
  And I fill in the "Content" editor with "<p>Some <em>HTML</em> content</p>"
  And I fill in "Tags" with "Test posts, Minimal"
  And I click "Create post"

  Then I should see the post "Test Post"
  When I look at the post "Test Post"
  Then I should see "Some HTML content" in it
  And I should see "Test posts" in it
  And I should see "Minimal" in it
  And its restriction should be "Not visible to students or guardians"
  And I should see "Teachers"
  And I should see "Rahul" in the posts teachers
  And I should not see "Students"
  And I should see "Posted by Rahul" in it


Scenario: Create a post without a title
  When I fill in the "Content" editor with "Content without a title"
  And I click "Create post"
  Then I should see "Title can't be blank"
  And I should be on the new post page
  And "Content" should be filled in with "<p>Content without a title</p>"


Scenario: Add student and teacher tags to a post
  When I fill in "Title" with "Tagged Post"
  And I tag the student "Ansh" in the post
  And I tag the teacher "Angela" in the post
  And I untag the teacher "Rahul" in the post
  And I tag the student "Sahana" in the post
  And I click "Create post"

  Then I should see the post "Tagged Post"
  When I look at the post "Tagged Post"
  And I should not see "Rahul" in the posts teachers
  And I should see "Angela" in the posts teachers
  And I should see "Ansh" in the posts students
  And I should see "Sahana" in the posts students


Scenario: Allow guardians to view a post
  When I fill in "Title" with "Permissions Post"
  And I check the checkbox "Guardians"
  And I click "Create post"

  Then I should see the post "Permissions Post"
  When I look at the post "Permissions Post"
  Then its restriction should be "Not visible to students"


Scenario: Allow anyone to view a post
  When I fill in "Title" with "Permissions Post"
  And I check the checkbox "Guardians"
  And I check the checkbox "Students"
  And I click "Create post"

  Then I should see the post "Permissions Post"
  When I look at the post "Permissions Post"
  Then it should have no restrictions
