@angular
Feature: Perform administrative functions on a profile

Teachers can activate a profile, reset its password, archive it and delete it

Background:
  Given I have logged in as the teacher Rahul

@current
Scenario: Delete a teacher from the people page
  Given a teacher Shalini exists
  When I am on the people page
  Then I should see the profile "Shalini Sekhar"
  When I click "Delete user"
  Then I should be on the people page
  And I should not see "Shalini Sekhar" in a "h3" element

  When I go to the people page
  Then I should not see "Shalini Sekhar" in a "h3" element

Scenario: Delete a teacher
  Given a teacher profile for Shalini exists
  When I am on the page for that profile
  And I click "Delete user"
  Then I should be on the people page
  And I should see "The user "Shalini Sekhar" has been deleted"

Scenario: Delete a student
  Given a student profile for Parvathy exists
  When I am on the page for that profile
  And I click "Delete user"
  Then I should be on the people page
  And I should see "The user "Parvathy Manjunath" has been deleted"

Scenario: Delete a guardian when the guardian has only one student
  Given a student profile for Parvathy exists
  And a guardian Manoj for that student exists
  When I am on the page for that profile
  And I click "Delete user" within the ".guardians" block
  Then I should be on the page for that profile
  And I should see "The user "Manoj Jain" has been deleted"
  And I should not see "Manoj Jain" within the ".guardians" block

Scenario: Remove a guardian when the guardian has multiple students
  Given a guardian Manoj with multiple students exists
  When I am on the page for one of the students
  And I click "Remove user" within the ".guardians" block
  Then I should be on the page for one of the students
  And I should see "The user "Manoj Jain" has been removed for the student "Roly Jain""
  And I should not see "Manoj Jain" within the ".guardians" block

Scenario: Activate a teacher with no email address
  Given a teacher profile for Shalini exists
  And the profile has no email address
  When I am on the page for that profile
  Then I should not see the link "Activate user"

Scenario: Activate a teacher
  Given a teacher profile for Shalini exists
  When I am on the page for that profile
  And I click "Activate user"
  Then I should be on the page for that profile
  And I should see "An email has been sent to the user with a randomly generated password"
  And I should see "Reset password"
  And "shalini@mail.com" should receive an email
  When they open the email
  Then they should see /^Activate your account$/ in the email subject

Scenario: Reset the password for a teacher
  Given a teacher profile for Shalini exists
  And the profile has been activated
  When I am on the page for that profile
  And I click "Reset password"
  Then I should be on the page for that profile
  And I should see "An email has been sent to the user with a randomly generated password"
  And "shalini@mail.com" should receive an email
  When they open the email
  Then they should see /^Your password has been reset$/ in the email subject

Scenario: Activate a student with no email address
  Given a student profile for Parvathy exists
  And the profile has no email address
  When I am on the page for that profile
  Then I should not see the link "Activate user"

Scenario: Activate a student
  Given a student profile for Parvathy exists
  When I am on the page for that profile
  And I click "Activate user"
  Then I should be on the page for that profile
  And I should see "An email has been sent to the user with a randomly generated password"
  And I should see "Reset password"
  And "parvathy@mail.com" should receive an email
  When they open the email
  Then they should see /^Activate your account$/ in the email subject

Scenario: Activate a guardian with no email address
  Given a student profile for Parvathy exists
  And a guardian Manoj for that student exists
  When I am on the page for that profile
  Then I should not see the link "Activate user" within the ".guardians" block

Scenario: Activate a guardian with an email address
  Given a student profile for Parvathy exists
  And a guardian Poonam for that student exists
  When I am on the page for that profile
  And I click "Activate user" within the ".guardians" block
  Then I should be on the page for the guardian
  And I should see "An email has been sent to the user with a randomly generated password"
  And I should see "Reset password"
  And "poonam@mail.com" should receive an email
  When they open the email
  Then they should see /^Activate your account$/ in the email subject

Scenario: Archive and unarchive a teacher
  Given a teacher profile for Shalini exists
  When I am on the page for that profile
  And I click "Archive user"
  Then I should be on the page for that profile
  And I should see "The user has been archived and can no longer login"
  When I click "Unarchive user"
  Then I should be on the page for that profile
  And I should see "The user is no longer archived and must be activated to allow a login"
  And I should see "Archive user"

Scenario: Archive and unarchive a student
  Given a student profile for Parvathy exists
  When I am on the page for that profile
  And I click "Archive user"
  Then I should be on the page for that profile
  And I should see "The user has been archived and can no longer login"
  When I click "Unarchive user"
  Then I should be on the page for that profile
  And I should see "The user is no longer archived and must be activated to allow a login"
  And I should see "Archive user"