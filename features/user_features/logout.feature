@angular
Feature: Logout from the site

As a user I want to be able to log out once I have logged in so that other people cannot access the website with my username

Scenario: Logout as a teacher
  Given I have logged in as a teacher "Rahul Sekhar"
  And I am on the home page
  And I click the element ".menu-icon"
  And I click "Log out"
  Then I should be on the login page
  And I should see "You have been logged out"