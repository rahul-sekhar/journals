Feature: View a post

As a user I should be able to view a post and see all its relevant data

Background:
  Given I have logged in as a teacher "Rahul Sekhar"

Scenario: View a post with only partial information
  Given a post about an ice cream factory visit exists
  When I am on the page for that post
  Then I should see "Ice cream factory visit"
  And I should see "The whole school went to the Daily Dairy"
  And I should see "25th October 2012"
  And I should see "Posted by Shalini"
  And a ".tags" block should not be present
  And a ".teachers" block should not be present
  And a ".students" block should not be present

Scenario: View a post with extended information
  Given a post about an ice cream factory visit with extended information exists
  When I am on the page for that post
  Then I should see "icecream" within the ".tags" block
  And I should see "visits" within the ".tags" block
  And I should see "Angela" within the ".teachers" block
  And I should see "Aditya" within the ".teachers" block
  And I should see "Ansh" within the ".students" block
  And I should see "Sahana" within the ".students" block

Scenario: View a post with no restrictions
  Given a post about an ice cream factory visit exists
  And that post is visible to students
  And that post is visible to guardians
  When I am on the page for that post
  Then I should not see "Restricted"

Scenario: View a post with student restrictions
  Given a post about an ice cream factory visit exists
  And that post is not visible to students
  And that post is visible to guardians
  When I am on the page for that post
  Then I should see "Restricted"
  And the span "Restricted" should have the title "Not visible to students"

Scenario: View a post with all restrictions
  Given a post about an ice cream factory visit exists
  And that post is not visible to students
  And that post is not visible to guardians
  When I am on the page for that post
  Then I should see "Restricted"
  And the span "Restricted" should have the title "Not visible to guardians or students"
