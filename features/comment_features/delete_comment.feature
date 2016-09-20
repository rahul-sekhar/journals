Feature: Delete a comment

Scenario: Delete a comment
  Given some base students and teachers exist
  And a post about an ice cream factory visit exists
  And that post has a comment "First comment" dated "25/10/2012" by the student "Ansh"
  And I have logged in as the teacher Rahul
  And I am on the page for that post

  When I look at the post "Ice cream factory visit"
  Then I should see "1 comment" in it
  When I click "Read more" in it
  Then I should see "First comment" in it
  And I delete the posts comment "First comment"
  Then I should see "Done"
  And I should not see "First Comment" in it
  When I click "Read less" in it
  Then I should see "No comments" in it