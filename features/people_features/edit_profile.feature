@angular
Feature: Edit a profile

I should be able to edit a student, guardian or teacher's profile

Background:
  Given I have logged in as a teacher "Rahul Sekhar"

Scenario: Change the profile name for a teacher
  Given a teacher profile for Shalini with all information exists
  And I am on the page for that profile
  
  When I click "Shalini Sekhar" in a "h3" element
  And I enter "Shalu Pandya" in the text input
  Then I should not see "Shalini Sekhar"
  And I should see "Shalu Pandya"
  
  When I go to the page for that profile
  Then I should not see "Shalini Sekhar"
  And I should see "Shalu Pandya" within the "h3" block

@current
Scenario: Edit fields for a teacher
  Given a teacher profile for Shalini with all information exists
  And I am on the page for that profile
  
  When I click "shalini@mail.com" in a "p" element
  And I enter "shalu@mail.com" in the text input
  Then I should not see "shalini@mail.com"
  And I should see "shalu@mail.com"

  When I click "080-12345" in a "p" element
  And I enter "1234" in the text input
  Then I should not see "080-12345"
  And I should see "1234"

  When I click "080-67890" in a "p" element
  And I enter " " in the text input
  Then I should not see "080-67890"
  And I should not see "Office phone"

  When I click "Some house, Banashankari, Bangalore - 55" in a "p" element
  And I enter "Some Other Address" in the textarea
  Then I should not see "Some house, Banashankari, Bangalore - 55"
  And I should see "Some Other Address"

  When I go to the page for that profile
  Then I should see "Shalini Sekhar"
  And I should see "1122334455"
  And I should not see "shalini@mail.com"
  And I should see "shalu@mail.com"
  And I should not see "080-12345"
  And I should see "1234"
  And I should not see "080-67890"
  And I should not see "Office phone"


Scenario: Edit a student profile
  Given a student profile for Parvathy with all information exists
  When I am on the page for that profile
  And I click "Edit profile"
  Then I should be on the edit page for that profile
  And "First name" should be filled in with "Parvathy"
  And "Last name" should be filled in with "Manjunath"
  And "Email" should be filled in with "parvathy@mail.com"
  And "Mobile" should be filled in with "12345678"
  And "Address" should be filled in with the lines: "Apartment,", "The hill,", "Darjeeling - 10"
  And "Home phone" should be filled in with "5678"
  And "Office phone" should be filled in with "1432"
  And "Birthday" should be filled in with "25-12-1996"
  And "Blood group" should be filled in with "B+"
  
  When I fill in "Last name" with "Jain"
  And I fill in "Address" with "Some other address"
  And I fill in "Birthday" with "20-11-2000"
  And I fill in "Blood group" with ""
  And I click "Save"

  Then I should be on the page for that profile
  And I should see "Parvathy Jain"
  And I should see "parvathy@mail.com"
  And I should see "12345678"
  And I should see "Some other address"
  And I should see "5678"
  And I should see "1432"
  And I should see "20-11-2000 (12 yrs)"
  And I should not see "Blood group"

Scenario: Edit a guardian profile
  Given a student profile for Parvathy exists
  And a guardian Manoj for that student exists
  When I am on the page for that profile
  And I click "Edit profile" within the ".guardians" block
  Then I should be on the edit page for the guardian profile
  And "First name" should be filled in with "Manoj"
  And "Last name" should be filled in with "Jain"
  
  When I fill in "First name" with ""
  And I fill in "Email" with "mail@jain.com"
  And I fill in "Office phone" with "12345"
  And I fill in "Address" with "Some address"
  And I click "Save"

  Then I should be on the page for the guardian
  And I should see "Jain"
  And I should see "mail@jain.com"
  And I should see "12345"
  And I should see "Some address"
  And I should not see "Mobile" within the ".guardians" block
  And I should not see "Home phone" within the ".guardians" block
