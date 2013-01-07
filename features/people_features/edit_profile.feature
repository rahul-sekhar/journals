Feature: Edit a profile

I should be able to edit a student, guardian or teacher's profile

Background:
  Given I have logged in as a teacher "Rahul Sekhar"

Scenario: Edit a teacher profile
  Given a teacher profile for Shalini with all information exists
  When I am on the page for that profile
  And I click "Edit profile"
  Then I should be on the edit page for that profile
  And "First name" should be filled in with "Shalini"
  And "Last name" should be filled in with "Sekhar"
  And "Email" should be filled in with "shalini@mail.com"
  And "Mobile" should be filled in with "1122334455"
  And "Address" should be filled in with the lines: "Some house,", "Banashankari,", "Bangalore - 55"
  And "Home phone" should be filled in with "080-12345"
  And "Office phone" should be filled in with "080-67890"
  
  When I fill in "First name" with "Shalu"
  And I fill in "Last name" with "Pandya"
  And I fill in "Email" with "shalu@mail.com"
  And I fill in "Home phone" with "990088"
  And I fill in "Office phone" with " "
  And I click "Save profile"

  Then I should be on the page for that profile
  And I should see "Shalu Pandya"
  And I should see "shalu@mail.com"
  And I should see "1122334455"
  And I should see "Some house, Banashankari, Bangalore - 55"
  And I should see "990088"
  And I should not see "Office Phone"

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
  And I click "Save profile"

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
  And I click "Save profile"

  Then I should be on the page for the guardian
  And I should see "Jain"
  And I should see "mail@jain.com"
  And I should see "12345"
  And I should see "Some address"
  And I should not see "Mobile" within the ".guardians" block
  And I should not see "Home phone" within the ".guardians" block
