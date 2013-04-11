Feature: Change password

As a user I should be able to change my password

Background:
  Given a teacher Rahul exists
  And I am on the login page
  And I log in with "rahul@mail.com" and "pass"
  When I select "Change password" from the user menu
  Then I should see "Change your password"


Scenario: Change my password with an incorrect current password
  When I look at the dialog
  And I fill in "Current password" with "pass1" in it
  And I fill in "New password" with "newpass" in it
  And I click "Change" in it
  Then I should see "Current password is incorrect"


Scenario: Change my password with an invalid new password
  When I look at the dialog
  And I fill in "Current password" with "pass" in it
  And I fill in "New password" with "new pass" in it
  And I click "Change" in it
  And I should see "New password is invalid"


Scenario: Change my password with a valid new password
  When I look at the dialog
  And I fill in "Current password" with "pass" in it
  And I fill in "New password" with "newpass" in it
  And I click "Change" in it
  Then I should see "Done"
  And I should not see "Change your password"

  When I select "Log out" from the user menu
  Then I should be on the login page
  When I log in with "rahul@mail.com" and "pass"
  Then I should see "Invalid email or password"
  And I should be on the login page

  When I log in with "rahul@mail.com" and "newpass"
  Then I should be on the posts page