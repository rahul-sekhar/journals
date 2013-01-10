Feature: Add profiles

Students, teachers and guardians are added by entering their first and last name. If a single name is given as a first name, it is saved as the last name. 

Guardians check for other guardians with the same name when they are added and ask whether the other students are siblings.

Background:
  Given I have logged in as a teacher "Rahul Sekhar"

Scenario: Add a teacher
  When I am on the people page
  And I click "Add teacher"
  Then I should see "First name"
  And I should see "Last name"
  And I should not see "Email"
  And I fill in "First name" with "Angela"
  And I fill in "Last name" with "Jain"
  And I click "Create"
  And I go to the teachers page
  Then I should see the heading "Angela Jain"

Scenario: Add a student
  When I am on the people page
  And I click "Add student"
  Then I should see "First name"
  And I should see "Last name"
  And I should not see "Email"
  And I fill in "First name" with "Jonathan"
  And I click "Create"
  And I go to the students page
  Then I should see the heading "Jonathan"

Scenario: Add a guardian
  Given a student profile for Parvathy exists
  And I am on the page for that profile
  When I click "Add guardian"
  Then I should see "First name"
  And I should see "Last name"
  And I should not see "Email"
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
  And I should see the option "John is a sibling of Parvathy - use the same login and profile for the guardian"
  And I should see the option "John is not a sibling of Parvathy - create another guardian with the same name but a different profile"
  When I select the option "John is not a sibling of Parvathy - create another guardian with the same name but a different profile"
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
  
  And I select the option "John is a sibling of Parvathy - use the same login and profile for the guardian"
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
  And I should see the option "John is a sibling of Parvathy and Roly - use the same login and profile for the guardian"
  And I should see the option "John is a sibling of Lucky - use the same login and profile for the guardian"
  And I should see the option "John is not a sibling of Parvathy and Roly or Lucky - create another guardian with the same name but a different profile"
  When I select the option "John is a sibling of Lucky - use the same login and profile for the guardian"
  And I click "Continue"
  Then I should be on the page for that profile
  And I should see "Manoj Jain" within the ".guardians" block

  When I go to the page for the guardian
  Then I should see the heading "Lucky Sekhar"
  And I should see the heading "John Doe"