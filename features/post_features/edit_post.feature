Feature: Edit a post

Background:
  Given a post about an ice cream factory visit with extended information exists
  And I have logged in as a teacher "Rahul Sekhar"

Scenario: Edit post
  Given I am on the page for that post
  When I click "Edit post"
  
  Then I should be on the edit page for that post
  And "Title" should be filled in with "Ice cream factory visit"
  And "Content" should be filled in with "The whole school went to the Daily Dairy factory for a visit. It was a very small factory and a quick quick quick visit..."
  And "Tags" should be filled in with "icecream, visits"
  And "Student tags" should have "Ansh Something, Sahana Somethingelse" selected
  And "Teacher tags" should have "Angela Jain, Aditya Pandya" selected
  And the checkbox "Guardians" should be unchecked
  And the checkbox "Students" should be checked

  When I fill in "Title" with "Different Title"
  And I fill in "Content" with "Some other content"
  And I fill in "Tags" with "visits, changes"
  And I unselect "Ansh Something" from "Student tags"
  And I select "Rahul Sekhar" from "Teacher tags"
  And I unselect "Angela Jain" from "Teacher tags"
  And I click "Save post"
  
  Then I should be on the page for that post
  And I should see "Different Title"
  And I should see "Some other content"
  And I should see "Tags: changes, visits"
  And I should not see "Angela" within the ".teachers" block
  And I should see "Aditya" within the ".teachers" block
  And I should see "Rahul" within the ".teachers" block
  And I should not see "Ansh" within the ".students" block
  And I should see "Sahana" within the ".students" block

Scenario: Edit post invalidly
  Given I am on the edit page for that post
  And I fill in "Title" with ""
  When I click "Save post"
  Then I should be on the edit page for that post
  And I should see "Title can't be blank"
  And "Title" should be filled in with ""