@angular
Feature: View a post

As a user I should be able to view a post and see all its relevant data

Background:
  Given I have logged in as the teacher Rahul

Scenario: View a post with only partial information
  Given a post about an ice cream factory visit exists
  When I am on the page for that post
  Then I should see "Ice cream factory visit"
  And I should see "The whole school went to the Daily Dairy"
  And I should see "25th October 2012"
  And I should see "Posted by Shalini"
  And I should not see "Tags"
  And I should not see "Teachers"
  And I should not see "Students"

Scenario: View a post with extended information
  Given a post about an ice cream factory visit with extended information exists
  When I am on the page for that post
  Then I should see "Tags: icecream, visits"
  And I should see "Teachers"
  And I should see "Angela" in the post teachers
  And I should see "Aditya" in the post teachers
  And I should see "Students"
  And I should see "Ansh" in the post students
  And I should see "Sahana" in the post students