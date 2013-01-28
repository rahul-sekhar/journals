Feature: Edit a comment

Background:
  Given some base students and teachers exist
  And a post about an ice cream factory visit exists
  And that post has a comment "First comment", dated "25/10/2012", posted by the student "Ansh"
  And I have logged in as a teacher "Rahul Sekhar"
  And I am on the page for that post

Scenario: Edit comment
  When I click "Edit" within the ".comments" block
  Then I should be on the edit page for that comment
  And "Enter comment" should be filled in with "First comment"
  When I fill in "Enter comment" with "Changed comment"
  And I click "Save"
  Then I should be on the page for that post
  And I should see "Changed comment" within the ".comments" block
  And I should not see "First comment" within the ".comments" block

Scenario: Edit comment with invalid data
  When I click "Edit" within the ".comments" block
  And I fill in "Enter comment" with ""
  And I click "Save"
  Then I should be on the page for that post
  And I should see "First comment" within the ".comments" block
  And I should see "Please enter a comment"