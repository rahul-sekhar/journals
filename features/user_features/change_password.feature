Feature: Change password

As a user I should be able to change my password

Background:
  Given a teacher "Rahul Sekhar" exists with the email "rahul@mail.com" and the password "pass"
  And I am on the login page
  And I fill in "Email" with "rahul@mail.com"
  And I fill in "Password" with "pass"
  And I click "Log in"

Scenario: Change my password with an incorrect current password
  When I click "Change password"
  Then I should be on the change password page
  When I fill in "Current password" with "pass1"
  And I fill in "New password" with "newpass"
  And I click the button "Change"
  Then I should be on the change password page
  And I should see "Current password is incorrect"

Scenario: Change my password with an invalid new password
  When I click "Change password"
  Then I should be on the change password page
  When I fill in "Current password" with "pass"
  And I fill in "New password" with "new pass"
  And I click the button "Change"
  Then I should be on the change password page
  And I should see "New password is invalid"

Scenario: Change my password with a valid new password
  When I click "Change password"
  Then I should be on the change password page
  When I fill in "Current password" with "pass"
  And I fill in "New password" with "newpass"
  And I click the button "Change"
  Then I should be on the posts page
  And I should see "Password changed successfully"

  And I click "Log out"
  And I fill in "Email" with "rahul@mail.com"
  And I fill in "Password" with "pass"
  And I click "Log in"
  Then I should be on the login page
  And I should see "Invalid email or password"

  And I fill in "Email" with "rahul@mail.com"
  And I fill in "Password" with "newpass"
  And I click "Log in"
  Then I should be on the posts page