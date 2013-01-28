Feature: Add profiles

Students, teachers and guardians are added by entering their first and last name. If a single name is given as a first name, it is saved as the last name. 

Guardians check for other guardians with the same name when they are added and ask whether the other students are siblings.

Background:
  Given I have logged in as a teacher "Rahul Sekhar"

Scenario: Add a teacher
  When I am on the people page
  And I click "Add teacher"
  And I fill in "First name" with "Angela"
  And I fill in "Last name" with "Jain"
  And I click "Create"
  And I go to the teachers page
  Then I should see the heading "Angela Jain"

Scenario: Add a student
  When I am on the people page
  And I click "Add student"
  And I fill in "First name" with "Jonathan"
  And I click "Create"
  And I go to the students page
  Then I should see the heading "Jonathan"

Scenario: Add a guardian
  Given a student profile for Parvathy exists
  And I am on the page for that profile
  When I click "Add guardian"
  Then I should not see "Email"
  And I fill in "First name" with "William"
  And I fill in "Last name" with "Tell"
  And I click "Create"
  Then I should be on the page for that profile
  And I should see "William Tell" within the ".guardians" block



Scenario: Add a guardian that already exists for a different student who is not a sibling
  Given a student profile for Parvathy exists
  And a guardian Manoj for that student exists
  And a student named "John Doe" exists
  
  And I am on the page for that profile
  When I click "Add guardian"
  And I fill in "First name" with "Manoj"
  And I fill in "Last name" with "Jain"
  And I click "Create"
  
  Then I should see "A guardian named Manoj Jain already exists"
  And I should see the option "John is a sibling of Parvathy Use the same login and profile for the guardian"
  And I should see the option "John is not a sibling of Parvathy Create another guardian with the same name but a different profile"
  When I select the option "John is not a sibling of Parvathy Create another guardian with the same name but a different profile"
  And I click "Continue"
  
  Then I should be on the page for that profile
  And I should see "Manoj Jain" within the ".guardians" block

  When I go to the page for the guardian
  Then I should see the heading "Parvathy Manjunath"
  And I should not see the heading "John Doe"



Scenario: Add a guardian that already exists for a different student who is a sibling
  Given a student profile for Parvathy exists
  And a guardian Manoj for that student exists
  And a student named "John Doe" exists
  
  And I am on the page for that profile
  When I click "Add guardian"
  And I fill in "First name" with "Manoj"
  And I fill in "Last name" with "Jain"
  And I click "Create"
  
  And I select the option "John is a sibling of Parvathy Use the same login and profile for the guardian"
  And I click "Continue"
  Then I should be on the page for that profile
  And I should see "Manoj Jain" within the ".guardians" block

  When I go to the page for the guardian
  Then I should see the heading "Parvathy Manjunath"
  And I should see the heading "John Doe"



Scenario: Add multiple guardians exist with different students 
  And a guardian Manoj with multiple students exists
  And a student named "Lucky Sekhar" exists
  And a guardian Manoj for that student exists
  
  And a student named "John Doe" exists
  And I am on the page for that profile
  When I click "Add guardian"
  And I fill in "First name" with "Manoj"
  And I fill in "Last name" with "Jain"
  And I click "Create"
  
  Then I should see "A guardian named Manoj Jain already exists"
  And I should see the option "John is a sibling of Parvathy and Roly Use the same login and profile for the guardian"
  And I should see the option "John is a sibling of Lucky Use the same login and profile for the guardian"
  And I should see the option "John is not a sibling of Parvathy and Roly or Lucky Create another guardian with the same name but a different profile"
  When I select the option "John is a sibling of Lucky Use the same login and profile for the guardian"
  And I click "Continue"
  Then I should be on the page for that profile
  And I should see "Manoj Jain" within the ".guardians" block

  When I go to the page for the guardian
  Then I should see the heading "Lucky Sekhar"
  And I should see the heading "John Doe"

Scenario: Add a teacher with an invalid email address
  When I am on the people page
  And I click "Add teacher"
  And I fill in "First name" with "Angela"
  And I fill in "Last name" with "Jain"
  And I fill in "Email" with "some invalid address"
  And I click "Create"
  Then I should be on the new teacher page
  And I should see "Email is invalid"
  And "First name" should be filled in with "Angela"
  And "Last name" should be filled in with "Jain"


Scenario: Add a student with a valid date of birth
  When I am on the people page
  And I click "Add student"
  And I fill in "First name" with "Angela"
  And I fill in "Last name" with "Jain"
  And I fill in "Birthday" with "18-2-2007"
  And I click "Create"
  Then I should see "Angela Jain"
  And I should see "18-02-2007"

Scenario: Add a student with an invalid date of birth
  When I am on the people page
  And I click "Add student"
  And I fill in "First name" with "Angela"
  And I fill in "Last name" with "Jain"
  And I fill in "Birthday" with "18th Feb 2007"
  And I click "Create"
  Then I should be on the new student page
  And I should see "Birthday is invalid"
  And "First name" should be filled in with "Angela"
  And "Last name" should be filled in with "Jain"