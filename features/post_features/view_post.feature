Feature: View a post

As a user I should be able to view a post and see all its relevant data

Scenario: View a post with only partial information
  Given a post about an ice cream factory visit exists
  And I have logged in as a teacher "Rahul Sekhar"
  And I am on the page for that post
  And I should see "Ice cream factory visit"
  And I should see "The whole school went to the Daily Dairy"
  And I should see "25th October 2012"
  And I should see "Posted by Shalini"
  And a ".tags" block should not be present
  And a ".teachers" block should not be present
  And a ".students" block should not be present

Scenario: View a post with extended information
  Given a post about an ice cream factory visit with extended information exists
  And I have logged in as a teacher "Rahul Sekhar"
  And I am on the page for that post
  Then I should see "icecream" within the ".tags" block
  And I should see "visits" within the ".tags" block
  And I should see "Angela" within the ".teachers" block
  And I should see "Aditya" within the ".teachers" block
  And I should see "Ansh" within the ".students" block
  And I should see "Sahana" within the ".students" block