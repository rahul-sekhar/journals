@angular
Feature: Login to the site

As a user I want to access the site by logging in and I want to be redirected to the page I intended to visit after I have logged in

Scenario: Access the main page without logging in
  Given I am on the home page
  Then I should be on the login page
  And I should see "Log in"
  And I should see "EMAIL"
  And I should see "PASSWORD"

Scenario: Enter an invalid password
  Given a teacher "Rahul Sekhar" exists with the email "rahul@mail.com" and the password "pass"
  When I am on the login page
  And I fill in "Email" with "rahul@mail.com"
  And I fill in "Password" with "pass1"
  And I click "Log in"
  Then I should be on the login page
  And I should see "Invalid email or password"

Scenario: Log in with a valid email and password, as a teacher
  Given a teacher "Rahul Sekhar" exists with the email "rahul@mail.com" and the password "pass"
  When I am on the login page
  And I fill in "Email" with "rahul@mail.com"
  And I fill in "Password" with "pass"
  And I click "Log in"
  Then I should be on the people page
  And I should see "You are signed in as Rahul Sekhar"

Scenario: Log in when accessing a page other than the home page
  Given PENDING a new posts page
  Given a teacher "Rahul Sekhar" exists with the email "rahul@mail.com" and the password "pass"
  When I am on the new post page
  Then I should see "Log in"
  When I fill in "Email" with "rahul@mail.com"
  And I fill in "Password" with "pass"
  And I click "Log in"
  Then I should be on the new post page
  And I should see "You are signed in as Rahul Sekhar"