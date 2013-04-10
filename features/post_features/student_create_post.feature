Feature: Create a post as a student

Students should be allowed to create posts but not set permissions, and cannot remove their own tag from the post

Background:
  Given some base students and teachers exist
  And I have logged in as the student Rahul
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
  And it should have no restrictions
  And I should not see "Teachers"
  And I should see "Students"
  And I should see "Rahul" in the posts students
  And I should see "Posted by Rahul" in it


Scenario: Add student and teacher tags to a post, without being able to remove self tag
  When I fill in "Title" with "Tagged Post"
  And I tag the student "Ansh" in the post
  And I tag the teacher "Angela" in the post
  And I untag the student "Rahul" in the post
  And I tag the student "Sahana" in the post
  And I untag the student "Ansh" in the post
  And I click "Create post"

  Then I should see the post "Tagged Post"
  When I look at the post "Tagged Post"
  And I should see "Rahul" in the posts students
  And I should not see "Ansh" in the posts students
  And I should see "Sahana" in the posts students

  And I should see "Angela" in the posts teachers


Scenario: Set post permissions
  Then I should not see "Permissions"
