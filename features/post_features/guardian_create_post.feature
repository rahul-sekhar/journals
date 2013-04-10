Feature: Create a post as a guardian

Guardians should be able to create posts and set only student permissions on the post. They should have all their students tagged initially, and must save the post with at least one tagged.

Background:
  Given some base students and teachers exist
  And I have logged in as the guardian Rahul
  And I have a student "Lucky Sekhar"
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
  And its restriction should be "Not visible to students"
  And I should not see "Teachers"
  And I should see "Students"
  And I should see "Roly" in the posts students
  And I should see "Lucky" in the posts students
  And I should see "Posted by Rahul" in it


Scenario: Add student and teacher tags to a post
  When I fill in "Title" with "Tagged Post"
  And I tag the student "Ansh" in the post
  And I untag the student "Roly" in the post
  And I tag the teacher "Angela" in the post
  And I tag the student "Sahana" in the post
  And I click "Create post"

  Then I should see the post "Tagged Post"
  When I look at the post "Tagged Post"
  And I should see "Angela" in the posts teachers
  And I should not see "Roly" in the posts students
  And I should see "Lucky" in the posts students
  And I should see "Ansh" in the posts students
  And I should see "Sahana" in the posts students


Scenario: Create a post without any own students tagged
  When I fill in "Title" with "Tagged Guardian Post"
  And I tag the student "Ansh" in the post
  And I untag the student "Roly" in the post
  And I untag the student "Lucky" in the post
  And I click "Create post"

  Then I should see "You must tag at least one of your own students"
  And I should be on the new post page


Scenario: Set post permissions
  Then I should not see "Guardians"

  When I fill in "Title" with "Permissions Post"
  And I check the checkbox "Students"
  And I click "Create post"

  Then I should see the post "Permissions Post"
  When I look at the post "Permissions Post"
  Then it should have no restrictions