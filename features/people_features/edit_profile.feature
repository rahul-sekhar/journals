@angular
Feature: Edit a profile
I should be able to edit a student, guardian or teacher's profile

Background:
  Given I have logged in as the teacher Rahul


Scenario: Change the profile name for a teacher
  Given a teacher Shalini exists
  And I am on the page for that profile

  When I look at the profile for "Shalini Sekhar"
  And I change the name to "Shalu Pandya"
  Then I should see a profile for "Shalu Pandya"
  Then I should not see a profile for "Shalini Sekhar"

  When I go to the page for that profile
  Then I should see a profile for "Shalu Pandya"
  And I should not see a profile for "Shalini Sekhar"


Scenario: Set an invalid profile name for a teacher
  Given a teacher Shalini exists
  And I am on the page for that profile

  When I look at the profile for "Shalini Sekhar"
  And I clear the name
  Then I should see a profile for "Shalini Sekhar"

  When I go to the page for that profile
  Then I should see a profile for "Shalini Sekhar"


Scenario: Edit fields for a teacher
  Given a teacher Shalini exists
  And I am on the page for that profile

  When I look at the profile for "Shalini Sekhar"
  And I change the field "Email" to "shalu@mail.com"
  Then I should see the field "Email" with "shalu@mail.com"

  When I change the field "Home phone" to "1234"
  Then I should see the field "Home phone" with "1234"

  When I clear the field "Office phone"
  Then I should not see the field "Office phone"

  When I change the field "Address" to "Some other address"
  Then I should see the field "Address" with "Some other address"

  When I go to the page for that profile
  And I look at the profile for "Shalini Sekhar"
  Then I should see the field "Mobile" with "1122334455"
  And I should see the field "Email" with "shalu@mail.com"
  And I should see the field "Home phone" with "1234"
  And I should not see the field "Office phone"
  And I should see the field "Address" with "Some other address"


Scenario: Add fields for a teacher
  Given a teacher Shalini exists
  And I am on the page for that profile

  When I look at the profile for "Shalini Sekhar"
  Then I should not see the add-field menu

  When I clear the field "Additional Emails"
  Then I should not see the field "Additional Emails"
  And I should see the add-field menu
  And the add-field menu should have the option "Additional Emails"

  When I add the field "Additional Emails" with "new@mail.com"
  Then I should see the field "Additional Emails" with "new@mail.com"
  And I should not see the add-field menu

  When I go to the page for that profile
  And I look at the profile for "Shalini Sekhar"
  Then I should see the field "Additional Emails" with "new@mail.com"
  And I should not see the add-field menu


Scenario: Set an invalid email for a student
  Given a student Parvathy exists
  And I am on the page for that profile

  When I look at the profile for "Parvathy Manjunath"
  And I change the field "Email" to "asdf"
  Then I should see the field "Email" with "parvathy.manjunath@mail.com"

  When I go to the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  Then I should see the field "Email" with "parvathy.manjunath@mail.com"


Scenario: Edit a student profile
  Given a student Parvathy exists
  And I am on the page for that profile

  When I look at the profile for "Parvathy Manjunath"
  And I change the name to "Parvathy   "
  Then I should see a profile for "Parvathy"
  And I should not see a profile for "Parvathy Manjunath"

  When I clear the field "Email"
  Then I should not see the field "Email"

  When I clear the field "Mobile"
  Then I should not see the field "Mobile"

  When I change the field "Blood group" to "A-"
  Then I should see the field "Blood group" with "A-"

  When I change the date field "Birthday" to "01-08-1980"
  Then I should see the field "Birthday" with "01-08-1980 (32 yrs)"

  When I go to the page for that profile
  Then I should see a profile for "Parvathy"
  And I should not see a profile for "Parvathy Manjunath"
  When I look at the profile for "Parvathy"
  Then I should not see the field "Email"
  And I should not see the field "Mobile"
  And I should see the field "Blood group" with "A-"
  And I should see the field "Birthday" with "01-08-1980 (32 yrs)"


Scenario: Clear student birthday
  Given a student Parvathy exists
  And I am on the page for that profile

  When I look at the profile for "Parvathy Manjunath"
  And I clear the date field "Birthday"
  Then I should not see the field "Birthday"

  When I go to the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  Then I should not see the field "Birthday"


Scenario: Add fields for a student
  Given a student Parvathy exists
  And I am on the page for that profile

  When I look at the profile for "Parvathy Manjunath"
  Then I should see the add-field menu
  And the add-field menu should have the option "Additional Emails"
  And the add-field menu should have the option "Notes"

  When I clear the date field "Birthday"
  Then I should not see the field "Birthday"
  And the add-field menu should have the option "Birthday"
  When I add the date field "Birthday" with "11-07-2001"
  Then I should see the field "Birthday" with "11-07-2001 (11 yrs)"

  When I clear the field "Blood group"
  Then the add-field menu should have the option "Blood group"

  When I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  Then I should see the add-field menu in it
  And the add-field menu should have the option "Additional Emails" in it
  And the add-field menu should have the option "Notes" in it
  And the add-field menu should have the option "Blood Group" in it
  And I should see the field "Birthday" with "11-07-2001 (11 yrs)"


Scenario: Add an invalid email field
  Given a student Parvathy exists
  And I am on the page for that profile

  When I look at the profile for "Parvathy Manjunath"
  Then I should see the field "Email" with "parvathy.manjunath@mail.com"
  And the add-field menu should not have the option "Email"

  When I clear the field "Email"
  Then I should not see the field "Email"
  And the add-field menu should have the option "Email"

  When I add the field "Email" with "invalidmail"
  Then I should not see the field "Email"
  And the add-field menu should have the option "Email"

  When I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  Then I should not see the field "Email"
  And the add-field menu should have the option "Email"


Scenario: Edit a guardian profile
  Given a student Parvathy exists
  And a guardian Poonam exists for that student
  When I am on the page for that profile

  When I look at the profile for "Parvathy Manjunath"
  And I look at the guardian "Poonam Jain"
  And I change the guardian name to "Parvathys Mom"
  When I look at the profile for "Parvathy Manjunath"
  Then I should not see the guardian "Poonam Jain"
  And I should see the guardian "Parvathys Mom"

  When I look at the guardian "Parvathys Mom"
  And I change the field "Email" to "jain@mail.com"
  Then I should see the field "Email" with "jain@mail.com"

  When I clear the field "Office Phone"
  Then I should not see the field "Office Phone"
  And the add-field menu should have the option "Office Phone" in it

  When I go to the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  Then I should not see the guardian "Poonam Jain"
  And I should see the guardian "Parvathys Mom"

  When I look at the guardian "Parvathys Mom"
  Then I should see the field "Email" with "jain@mail.com"
  And I should not see the field "Office Phone"
  And the add-field menu should have the option "Office Phone" in it


Scenario: Add fields for a guardian
  Given a student Parvathy exists
  And a guardian Poonam exists for that student
  When I am on the page for that profile

  When I look at the profile for "Parvathy Manjunath"
  And I look at the guardian "Poonam Jain"
  Then I should see the add-field menu in it
  And the add-field menu should have the option "Additional Emails" in it
  And the add-field menu should have the option "Notes" in it

  When I add the field "Notes" with "Some notes here"
  Then I should see the field "Notes" with "Some notes here"
  And the add-field menu should not have the option "Notes" in it

  When I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  And I look at the guardian "Poonam Jain"
  Then I should see the add-field menu in it
  And the add-field menu should have the option "Additional Emails" in it
  And the add-field menu should not have the option "Notes" in it
  And I should see the field "Notes" with "Some notes here"


Scenario: Add an invalid email field for a guardian
  Given a student Parvathy exists
  And a guardian Poonam exists for that student
  When I am on the page for that profile

  When I look at the profile for "Parvathy Manjunath"
  And I look at the guardian "Poonam Jain"
  Then I should see the field "Email" with "poonam@mail.com"
  And the add-field menu should not have the option "Email" in it

  When I clear the field "Email"
  Then I should not see the field "Email"
  And the add-field menu should have the option "Email" in it

  When I add the field "Email" with "invalid@mail"
  Then I should not see the field "Email"
  And the add-field menu should have the option "Email" in it

  When I am on the page for that profile
  And I look at the profile for "Parvathy Manjunath"
  And I look at the guardian "Poonam Jain"
  Then I should not see the field "Email"
  And the add-field menu should have the option "Email" in it
