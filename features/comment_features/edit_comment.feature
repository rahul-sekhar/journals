Feature: Edit a comment

Background:
  Given some base students and teachers exist
  And a post about an ice cream factory visit exists
  And that post has a comment "First comment" dated "25/10/2012" by the student "Ansh"
  And I have logged in as the teacher Rahul
  And I am on the page for that post
  And I look at the post "Ice cream factory visit"
  And I click "Read more" in it

Scenario: Edit comment
  When I edit the posts comment "First comment"
  Then the comment editor should be filled with "First comment"
  When I fill in the comment editor with "Changed comment"

  Then I should see "Done"
  And I should not see "First comment" in the posts comments
  And I should see "Changed comment" in the posts comments

Scenario: Edit comment with invalid data
  When I edit the posts comment "First comment"
  And I fill in the comment editor with ""

  Then I should see "Please enter a comment"
  And I should see "First comment" in the posts comments