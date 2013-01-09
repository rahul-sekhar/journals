Feature: Manage mentors and mentees

Teachers can view and manage mentors and mentees

Background:
  Given I have logged in as a teacher "Rahul Sekhar"

Scenario: View a student with no mentors
  Given a student profile for Parvathy exists
  And I am on the page for that profile
  Then I should see "Mentors"
  And I should see "None" within the ".mentors" block


Scenario: View a student with mentors, add and remove mentors
  Given a student profile for Parvathy exists
  And the teachers Angela, Shalini, Aditya and Sharad exist
  And that student belongs to the mentors "Angela, Sharad"
  And I am on the page for that profile
  Then I should see "Angela Jain" within the ".mentors ul" block
  And I should see "Sharad Jain" within the ".mentors ul" block
  And "Remaining teachers" should have the options "Shalini Sekhar, Aditya Pandya, Rahul Sekhar"

  When I select "Shalini Sekhar" from "Remaining teachers"
  And I click "Add mentor"
  Then I should be on the page for that profile
  And I should see "Shalini Sekhar has been added as a mentor for Parvathy Manjunath"
  And I should see "Shalini Sekhar" within the ".mentors ul" block
  And "Remaining teachers" should have the options "Aditya Pandya, Rahul Sekhar"

  When I click "Remove" near "Angela Jain" in a list item
  Then I should be on the page for that profile
  And I should see "Angela Jain is no longer a mentor for Parvathy Manjunath"
  And I should not see "Angela Jain" within the ".mentors ul" block
  And "Remaining teachers" should have the options "Angela Jain, Aditya Pandya, Rahul Sekhar"

Scenario: View a teacher with mentees, add and remove mentees
  Given the students Roly, Lucky and Jumble exist
  And I have the mentees "Lucky, Jumble"
  And I am on the page for my profile
  Then I should see "Lucky Sekhar" within the ".mentees ul" block
  And I should see "Jumble Sekhar" within the ".mentees ul" block
  And "Remaining students" should have the options "Roly Sekhar"

  When I select "Roly Sekhar" from "Remaining students"
  And I click "Add mentee"
  Then I should be on the page for my profile
  And I should see "Rahul Sekhar has been added as a mentor for Roly Sekhar"
  And I should see "Roly Sekhar" within the ".mentees ul" block
  And I should not see the field "Remaining students"

  When I click "Remove" near "Jumble Sekhar" in a list item
  Then I should be on the page for my profile
  And I should see "Rahul Sekhar is no longer a mentor for Jumble Sekhar"
  And I should not see "Jumble Sekhar" within the ".mentees ul" block
  And "Remaining students" should have the options "Jumble Sekhar"