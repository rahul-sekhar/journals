Feature: Manage mentors and mentees

Teachers can view and manage mentors and mentees

Background:
  Given I have logged in as a teacher "Rahul Sekhar"

Scenario: View a student with no mentors
  Given a student profile for Parvathy exists
  And I am on the page for that profile
  Then I should see "Mentor"
  And I should see "None" within the ".mentors" block


Scenario: View a student with mentors, add and remove mentors
  Given a student profile for Parvathy exists
  And the teachers Angela, Shalini, Aditya and Sharad exist
  And that student belongs to the mentors "Angela, Sharad"
  And I am on the page for that profile
  Then I should see "Angela" within the ".mentors ul" block
  And I should see "Sharad" within the ".mentors ul" block
  And "Remaining teachers" should have the options "Shalini, Aditya, Rahul"

  When I select "Shalini" from "Remaining teachers"
  And I click "Add" within the ".mentors" block
  Then I should be on the page for that profile
  And I should see "Shalini Sekhar is now Parvathy Manjunath's mentor"
  And I should see "Shalini" within the ".mentors ul" block
  And "Remaining teachers" should have the options "Aditya, Rahul"

  When I click "Remove" near "Angela" in a list item
  Then I should be on the page for that profile
  And I should see "Angela Jain is no longer Parvathy Manjunath's mentor"
  And I should not see "Angela" within the ".mentors ul" block
  And "Remaining teachers" should have the options "Angela, Aditya, Rahul"

Scenario: View a teacher with mentees, add and remove mentees
  Given the students Roly, Lucky and Jumble exist
  And I have the mentees "Lucky, Jumble"
  And I am on the page for my profile
  Then I should see "Lucky " within the ".mentees ul" block
  And I should see "Jumble" within the ".mentees ul" block
  And "Remaining students" should have the options "Roly"

  When I select "Roly" from "Remaining students"
  And I click "Add" within the ".mentees" block
  Then I should be on the page for my profile
  And I should see "Rahul Sekhar is now Roly Sekhar's mentor"
  And I should see "Roly" within the ".mentees ul" block
  And I should not see the field "Remaining students"

  When I click "Remove" near "Jumble" in a list item
  Then I should be on the page for my profile
  And I should see "Rahul Sekhar is no longer Jumble Sekhar's mentor"
  And I should not see "Jumble" within the ".mentees ul" block
  And "Remaining students" should have the options "Jumble"