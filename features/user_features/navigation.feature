Feature: Navigate the site

As a user I want to be able to access each page of the site through a menu

Scenario: Navigate pages as teacher
  Given I have logged in as a teacher "Rahul Sekhar"
  Then I should be on the posts page
  When I click "New post"
  Then I should be on the new post page
  When I click "View posts"
  Then I should be on the posts page
  When I click "People"
  Then I should be on the people page

Scenario: View your profile
  Given I have logged in as a teacher "Rahul Sekhar"
  And I click "Your profile"
  Then I should be on the page for my profile