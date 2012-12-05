Feature: Login to the site

As a user I want to access the site by logging in and I want to be redirected to the page I intended to visit after I have logged in

Scenario: Access the main page without logging in
Given I am on the home page
Then I should be on the login page
And I should see "Log in"
And I should see "Username"
And I should see "Password"

Scenario: Enter an invalid password
Given a user "rahul" with the password "pass" exists
When I am on the login page
And I fill in "Username" with "rahul"
And I fill in "Password" with "pass1"
And I click "Log in"
Then I should be on the login page
And I should see "Invalid username or password"

Scenario: Log in with a valid username and password
Given a user "rahul" with the password "pass" exists
When I am on the login page
And I fill in "Username" with "rahul"
And I fill in "Password" with "pass"
And I click "Log in"
Then show me the page
Then I should be on the home page

Scenario: Log in when accessing a page other than the home page
Given PENDING: need another page