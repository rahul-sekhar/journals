@angular
Feature: View a post

As a user I should be able to view a post and see all its relevant data

Background:
  Given I have logged in as the teacher Rahul

Scenario: View a post with only partial information
  Given a post about an ice cream factory visit exists
  When I am on the page for that post
  And I look at the post "Ice cream factory visit"
  Then I should see "The whole school went to the Daily Dairy" in it
  And I should see "25th October 2012" in it
  And I should see "Posted by Shalini" in it
  And I should not see "Tags" in it
  And I should not see "Teachers" in it
  And I should not see "Students" in it

Scenario: View a post with extended information
  Given a post about an ice cream factory visit with extended information exists
  When I am on the page for that post
  And I look at the post "Ice cream factory visit"
  Then I should see "Tags: icecream, visits" in it
  And I should see "Teachers" in it
  And I should see "Angela" in the posts teachers
  And I should see "Aditya" in the posts teachers
  And I should see "Students" in it
  And I should see "Ansh" in the posts students
  And I should see "Sahana" in the posts students


Scenario: Click on users name to reach profile
  Given a post about an ice cream factory visit with extended information exists
  When I am on the page for that post
  And I look at the post "Ice cream factory visit"
  And I click "Shalini" in the posts info
  Then I should see "Profile: Shalini Sekhar"

  When I am on the page for that post
  And I look at the post "Ice cream factory visit"
  And I click "Ansh" in the posts students
  Then I should see "Profile: Ansh"