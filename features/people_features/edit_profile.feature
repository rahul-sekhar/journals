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
  Then I should not see "Shalini Sekhar" in a "h3" element
  And I should see "Shalu Pandya"
  
  When I go to the page for that profile
  Then I should not see "Shalini Sekhar"
  And I should see "Shalu Pandya" in a "h3" element


Scenario: Set an invalid profile name for a teacher
  Given a teacher profile for Shalini with all information exists
  And I am on the page for that profile
  
  When I click "Shalini Sekhar" in a "h3" element
  And I enter " " in the text input
  Then I should see "Shalini Sekhar" in a "h3" element
  
  When I go to the page for that profile
  Then I should see "Shalini Sekhar" in a "h3" element


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
  And I should not see "Office Phone" in a ".field-name" element

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
  And I should not see "Office Phone" in a ".field-name" element


Scenario: Add fields for a teacher
  Given a teacher profile for Shalini with all information exists
  And I am on the page for that profile

  Then I should not see "Add field" in a ".add-field-menu" element
  And I should not see "Additional Emails" in a ".add-field-menu" element
  
  When I click "shalu@short.com" in a "p" element
  And I enter " " in the text input
  Then I should not see "Additional Emails" in a ".field-name" element
  And I should see "Add field" in a ".add-field-menu" element
  And I should see "Additional Emails" in a ".add-field-menu" element

  When I click "Additional Emails"
  And I enter "new@mail.com" in the text input
  Then I should see "new@mail.com"
  Then I should see "Additional Emails" in a ".field-name" element
  And I should not see "Add field" in a ".add-field-menu" element
  And I should not see "Additional Emails" in a ".add-field-menu" element

  When I go to the page for that profile
  Then I should see "new@mail.com"
  Then I should see "Additional Emails" in a ".field-name" element
  And I should not see "Add field" in a ".add-field-menu" element
  And I should not see "Additional Emails" in a ".add-field-menu" element


Scenario: Set an invalid email for a student
  Given a student profile for Parvathy with all information exists
  And I am on the page for that profile

  When I click "parvathy@mail.com" in a "p" element
  And I enter "asdf" in the text input
  Then I should see "parvathy@mail.com"
  And I should not see "asdf"


Scenario: Edit a student profile
  Given a student profile for Parvathy with all information exists
  And I am on the page for that profile
  
  When I click "Parvathy Manjunath" in a "h3" element
  And I enter " Parvathy  " in the text input
  Then I should not see "Parvathy Manjunath" in a "h3" element
  And I should see "Parvathy"

  When I click "parvathy@mail.com" in a "p" element
  And I enter " " in the text input
  Then I should not see "parvathy@mail.com"
  And I should not see "Email" in a ".field-name" element

  When I click "12345678" in a "p" element
  And I enter " " in the text input
  Then I should not see "12345678"
  And I should not see "Mobile" in a ".field-name" element

  When I click "B\+" in a "p" element
  And I enter "A-" in the text input
  Then I should not see "B+"
  And I should see "A-"

  When I click "25-12-1996" in a "p" element
  And I enter the date "01-05-1980"
  Then I should not see "25-12-1996"
  And I should see "01-05-1980"

  When I go to the page for that profile
  Then I should not see "Parvathy Manjunath"
  And I should see "Parvathy"
  And I should not see "parvathy@mail.com"
  And I should not see "Email" in a ".field-name" element
  And I should not see "12345678"
  And I should not see "Mobile" in a ".field-name" element
  And I should not see "B+"
  And I should see "A-"
  And I should not see "25-12-1996"
  And I should see "01-05-1980"


Scenario: Clear student birthday
  Given a student profile for Parvathy with all information exists
  And I am on the page for that profile
  Then I should see "Birthday" in a ".field-name" element

  When I click "25-12-1996" in a "p" element
  And I click the element ".clear-date"
  Then I should not see "25-12-1996"
  And I should not see "Birthday" in a ".field-name" element

  When I go to the page for that profile
  Then I should not see "25-12-1996"
  And I should not see "Birthday" in a ".field-name" element


Scenario: Add fields for a student
  Given a student profile for Parvathy with all information exists
  And I am on the page for that profile

  Then I should see "Add field" in a ".add-field-menu" element
  And I should see "Additional Emails" in a ".add-field-menu" element
  And I should see "Notes" in a ".add-field-menu" element
  
  When I click "25-12-1996" in a "p" element
  And I click the element ".clear-date"
  And I click "Birthday" within the ".add-field-menu" block
  And I enter the date "11-07-2001"

  When I click "B\+" in a "p" element
  And I enter " " in the text input

  When I am on the page for that profile
  Then I should see "Add field" in a ".add-field-menu" element
  And I should see "Additional Emails" in a ".add-field-menu" element
  And I should see "Notes" in a ".add-field-menu" element
  And I should see "Blood Group" in a ".add-field-menu" element
  And I should not see "B+"
  And I should not see "Blood Group" in a ".field-name" element
  And I should not see "25-12-1996"
  And I should see "11-07-2001"


Scenario: Add an invalid email field
  Given a student profile for Parvathy exists
  And I am on the page for that profile
  Then I should see "Email\b" in a ".field-name" element
  And I should not see "Email\b" in a ".add-field-menu" element
  
  When I click "parvathy@mail.com" in a "p" element
  And I enter " " in the text input
  Then I should not see "Email\b" in a ".field-name" element
  And I should see "Email\b" in a ".add-field-menu" element

  When I click "Email\b" in a ".add-field-menu a" element
  And I enter "invalidmail" in the text input
  And I should not see "Email\b" in a ".field-name" element
  And I should see "Email\b" in a ".add-field-menu" element

  When I am on the page for that profile
  Then I should not see "Email\b" in a ".field-name" element
  And I should see "Email\b" in a ".add-field-menu" element


Scenario: Edit a guardian profile
  Given a student profile for Parvathy exists
  And a guardian Poonam for that student exists
  When I am on the page for that profile

  When I click "Poonam Jain" in a "h4" element
  And I enter "Parvathys Mom" in the text input
  Then I should not see "Poonam Jain"
  And I should see "Parvathys Mom" within the ".guardians" block

  When I click "poonam@mail.com" in a "p" element
  And I enter "jain@mail.com" in the text input
  Then I should not see "poonam@mail.com"
  And I should see "jain@mail.com" within the ".guardians" block

  When I click "333-444" in a "p" element
  And I enter " " in the text input
  Then I should not see "333-444"
  And I should not see "Office Phone" in a ".field-name" element within the ".guardians" block

  When I go to the page for that profile
  Then I should not see "Manoj Jain"
  And I should see "Parvathys Mom"
  And I should not see "poonam@mail.com"
  And I should see "jain@mail.com"
  And I should not see "333-444"
  And I should not see "Office Phone" in a ".field-name" element within the ".guardians" block


Scenario: Add fields for a guardian
  Given a student profile for Parvathy exists
  And a guardian Poonam for that student exists
  When I am on the page for that profile

  Then I should see "Add field" in a ".add-field-menu" element within the ".guardians" block
  And I should see "Additional Emails" in a ".add-field-menu" element within the ".guardians" block
  And I should see "Notes" in a ".add-field-menu" element within the ".guardians" block
  And I should not see "Notes" in a ".field-name" element within the ".guardians" block
  
  When I click "Notes" within the ".guardians .add-field-menu" block
  And I enter "Some notes here" in the textarea within the ".guardians" block

  And I should see "Notes" in a ".field-name" element within the ".guardians" block
  And I should see "Some notes here" within the ".guardians" block
  And I should not see "Notes" in a ".add-field-menu" element within the ".guardians" block

  When I am on the page for that profile
  Then I should see "Add field" in a ".add-field-menu" element within the ".guardians" block
  And I should see "Additional Emails" in a ".add-field-menu" element within the ".guardians" block
  And I should not see "Notes" in a ".add-field-menu" element within the ".guardians" block
  And I should see "Notes" in a ".field-name" element within the ".guardians" block
  And I should see "Some notes here" within the ".guardians" block


Scenario: Add an invalid email field for a guardian
  Given a student profile for Parvathy exists
  And a guardian Poonam for that student exists
  When I am on the page for that profile
  Then I should see "Email\b" in a ".field-name" element within the ".guardians" block
  And I should not see "Email\b" in a ".add-field-menu" element within the ".guardians" block
  
  When I click "poonam@mail.com" in a "p" element within the ".guardians" block
  And I enter " " in the text input within the ".guardians" block
  Then I should not see "Email\b" in a ".field-name" element within the ".guardians" block
  And I should see "Email\b" in a ".add-field-menu" element within the ".guardians" block

  When I click "Email\b" in a ".add-field-menu a" element within the ".guardians" block
  And I enter "invalidmail" in the text input within the ".guardians" block
  And I should not see "Email\b" in a ".field-name" element within the ".guardians" block
  And I should see "Email\b" in a ".add-field-menu" element within the ".guardians" block

  When I am on the page for that profile
  Then I should not see "Email\b" in a ".field-name" element within the ".guardians" block
  And I should see "Email\b" in a ".add-field-menu" element within the ".guardians" block