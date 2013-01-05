Feature: Delete a comment
  
Scenario: Delete a comment
  Given some base students and teachers exist
  And a post about an ice cream factory visit exists
  And a comment on the post "Ice cream factory visit" exists with content "First comment", date "25/10/2012", posted by the student "Ansh"
  And I have logged in as a teacher "Rahul Sekhar"
  And I am on the page for that post
  
  When I click "Delete" within the ".comments" block
  Then that comment should be destroyed
  And I should be on the page for that post
  And I should see "The comment has been deleted"
  And I should not see "First comment"