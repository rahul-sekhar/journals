Feature: Login to the site

As a user I want to access the site by logging in and I want to be redirected to the page I intended to visit after I have logged in

Scenario: Access the main page without logging in
  Given I am on the home page
  Then I should be on the login page

Scenario: Enter invalid email or password
  Given a teacher Rahul exists
  When I am on the login page
  And I log in with "rahul@mail.com" and "pas"
  Then I should be on the login page
  And I should see "Invalid email or password"

  And I log in with "rahul@mail.com" and ""
  Then I should be on the login page
  And I should see "Invalid email or password"

  And I log in with "rahul1@mail.com" and "pass"
  Then I should be on the login page
  And I should see "Invalid email or password"

Scenario: Log in with a valid email and password
  Given a teacher Rahul exists
  When I am on the login page
  And I log in with "rahul@mail.com" and "pass"
  Then I should be on the posts page
  And I should see "You are signed in as Rahul Sekhar"


Scenario: Log in when accessing a page other than the home page
  Given a teacher Rahul exists
  When I am on the people page
  Then I should be on the login page
  When I log in with "rahul@mail.com" and "pass"
  Then I should be on the people page
  And the page heading should be "People"
  And I should see "You are signed in as Rahul Sekhar"