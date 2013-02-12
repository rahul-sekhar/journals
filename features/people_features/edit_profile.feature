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


Scenario: Set an invalid profile name for a teacher
  Given a teacher profile for Shalini with all information exists
  And I am on the page for that profile
  
  When I click "Shalini Sekhar" in a "h3" element
  And I enter " " in the text input
  Then I should see "Shalini Sekhar" within the "h3" block
  
  When I go to the page for that profile
  Then I should see "Shalini Sekhar" within the "h3" block


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
  Then I should not see "Parvathy Manjunath"
  And I should see "Parvathy"

  When I click "parvathy@mail.com" in a "p" element
  And I enter " " in the text input
  Then I should not see "parvathy@mail.com"
  And I should not see "Email"

  When I click "12345678" in a "p" element
  And I enter " " in the text input
  Then I should not see "12345678"
  And I should not see "Mobile"

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
  And I should not see "Email"
  And I should not see "12345678"
  And I should not see "Mobile"
  And I should not see "B+"
  And I should see "A-"
  And I should not see "25-12-1996"
  And I should see "01-05-1980"


Scenario: Clear student birthday
  Given a student profile for Parvathy with all information exists
  And I am on the page for that profile
  When I click "25-12-1996" in a "p" element
  And I click the element ".clear-date"
  Then I should not see "25-12-1996"
  And I should not see "Birthday"

  When I go to the page for that profile
  Then I should not see "25-12-1996"
  And I should not see "Birthday"


Scenario: Edit a guardian profile
  Given a student profile for Parvathy exists
  And a guardian Poonam for that student exists
  When I am on the page for that profile

  When I click "Poonam Jain" in a "h4" element
  And I enter "Parvathys Mom" in the text input
  Then I should not see "Manoj Jain"
  And I should see "Parvathys Mom"

  When I click "poonam@mail.com" in a "p" element
  And I enter "jain@mail.com" in the text input
  Then I should not see "poonam@mail.com"
  And I should see "jain@mail.com"

  When I click "333-444" in a "p" element
  And I enter " " in the text input
  Then I should not see "333-444"
  And I should not see "Office Phone"

  When I go to the page for that profile
  Then I should not see "Manoj Jain"
  And I should see "Parvathys Mom"
  And I should not see "poonam@mail.com"
  And I should see "jain@mail.com"
  And I should not see "333-444"
  And I should not see "Office Phone"
