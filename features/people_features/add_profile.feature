@angular
Feature: Add profiles

Students, teachers and guardians are added by entering their first and last name.

Guardians check for other guardians with the same name when they are added and ask whether the other students are siblings.

Background:
  Given I have logged in as the teacher Rahul


Scenario: Add a teacher
  When I am on the people page
  And I add the teacher "Angela Jain"
  Then I should see a profile for "Angela Jain"

  When I go to the people page
  Then I should see a profile for "Angela Jain"


Scenario: Add a student
  When I am on the people page
  And I add the student "Johnny"
  Then I should see a profile for "Johnny"

  When I go to the students page
  Then I should see a profile for "Johnny"


Scenario: Add a guardian
  Given a student Parvathy exists
  And I am on the page for that profile

  When I look at the profile for "Parvathy Manjunath"
  And I add the guardian "William Tell"
  Then I should see the guardian "William Tell"
  And I should see "Done"

  When I go to the students page
  And I look at the profile for "Parvathy Manjunath"
  Then I should see the guardian "William Tell"


Scenario: Add a guardian that already exists for a different student who is not a sibling
  Given a student Parvathy exists
  And a guardian Poonam exists for that student
  And a student "John Doe" exists

  When I am on the page for that profile
  And I look at the profile for "John Doe"
  And I add the guardian "Poonam Jain"

  Then I should see "A guardian named Poonam Jain already exists"
  And I should see an option containing "John Doe is a sibling of Parvathy"
  And I should see an option containing "John Doe is not a sibling of Parvathy"

  When I select the option containing "John Doe is not a sibling of Parvathy"
  And I click "Continue"
  Then I should see "Done"
  And I should see the guardian "Poonam Jain"

  When I go to the page for that profile
  And I look at the profile for "John Doe"
  Then I should see the guardian "Poonam Jain"

  When I go to the page for the guardian
  Then I should see a profile for "Parvathy Manjunath"
  And I should not see a profile for "John Doe"


Scenario: Add a guardian that already exists for a different student who is a sibling
  Given a student Parvathy exists
  And a guardian Poonam exists for that student
  And a student "John Doe" exists

  When I am on the page for that profile
  And I look at the profile for "John Doe"
  And I add the guardian "Poonam Jain"
  And I select the option containing "John Doe is a sibling of Parvathy"
  And I click "Continue"
  Then I should see "Done"
  And I should see the guardian "Poonam Jain"

  When I go to the page for that profile
  And I look at the profile for "John Doe"
  Then I should see the guardian "Poonam Jain"

  When I go to the page for the guardian
  Then I should see a profile for "Parvathy Manjunath"
  And I should see a profile for "John Doe"


Scenario: Add a guardian when multiple guardians with the same name exist with different students
  And a guardian Manoj with multiple students exists
  And a student "Lucky Sekhar" exists
  And a guardian "Manoj Jain" exists for that student
  And a student "John Doe" exists

  And I am on the page for that profile
  And I look at the profile for "John Doe"
  And I add the guardian "Manoj Jain"

  Then I should see "A guardian named Manoj Jain already exists"
  And I should see an option containing "John Doe is a sibling of Parvathy and Roly"
  And I should see an option containing "John Doe is a sibling of Lucky"
  And I should see an option containing "John Doe is not a sibling of Parvathy and Roly or Lucky"
  When I select the option containing "John Doe is a sibling of Lucky"
  And I click "Continue"
  Then I should see "Done"
  And I should see the guardian "Manoj Jain"

  When I go to the page for the guardian
  Then I should see a profile for "Lucky Sekhar"
  And I should see a profile for "John Doe"
  And I should not see a profile for "Roly Sekhar"
