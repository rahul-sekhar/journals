@angular
Feature: Edit a post

Background:
  Given a post about an ice cream factory visit with extended information exists
  And I have logged in as the teacher Rahul

Scenario: Edit post
  Given I am on the page for that post
  And I look at the post "Ice cream factory visit"
  When I click "Edit post" in it

  Then I should be on the edit page for that post
  And I should not see "Loading"
  And "Title" should be filled in with "Ice cream factory visit"
  And the "Content" editor should be filled in with "<p>The whole school went to the Daily Dairy factory for a visit. It was a very small factory and a quick quick quick visit...</p>"
  And "Tags" should be filled in with "icecream, visits"

  When I look at the student tags section
  Then I should see "Ansh" in it
  And I should see "Sahana" in it

  When I look at the teacher tags section
  Then I should see "Aditya" in it
  And I should see "Angela" in it
  And I should not see "Rahul" in it

  And the checkbox "Guardians" should be unchecked
  And the checkbox "Students" should be checked

  When I fill in "Title" with "Different Title"
  And I fill in the "Content" editor with "Some other content"
  And I fill in "Tags" with "visits, changes"
  And I untag the student "Ansh" in the post
  And I tag the teacher "Rahul" in the post
  And I untag the teacher "Angela" in the post
  And I click "Save post"

  Then I should see the post "Different Title"
  When I look at the post "Different Title"
  Then I should see "Some other content" in it
  And I should see "Tags: changes, visits" in the posts info
  And I should not see "Angela" in the posts teachers
  And I should see "Aditya" in the posts teachers
  And I should see "Rahul" in the posts teachers
  And I should not see "Ansh" in the posts students
  And I should see "Sahana" in the posts students

Scenario: Edit post invalidly
  Given I am on the edit page for that post
  And I fill in "Title" with ""
  When I click "Save post"
  Then I should see "Title can't be blank"
  And I should be on the edit page for that post
  And "Title" should be filled in with ""