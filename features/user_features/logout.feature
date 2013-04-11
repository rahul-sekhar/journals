Feature: Logout from the site

As a user I want to be able to log out once I have logged in so that other people cannot access the website with my username

Scenario: Logout as a teacher
  Given I have logged in as the teacher Rahul
  And I am on the home page
  When I select "Log out" from the user menu
  Then I should be on the login page
  And I should see "You have been logged out"