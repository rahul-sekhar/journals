@current
Feature: Manage subjects

Background:
  Given I have logged in as the teacher Rahul


Scenario: View the subjects page with no subjects
  When I am on the subjects page
  Then the page heading should be "Academic records"
  And I should see "There are no subjects yet"


Scenario: View the subjects page when there are subjects
  Given the subject "Math" exists
  And the subject "English" exists
  When I am on the subjects page
  Then the page heading should be "Academic records"
  And I should see the subject "Math"
  And I should see the subject "English"


Scenario: Delete a subject
  Given the subject "Math" exists
  And the subject "English" exists
  When I am on the subjects page
  And I delete the subject "English"
  Then I should not see the subject "English"
  And I should see the subject "Math"

  When I am on the subjects page
  Then I should not see the subject "English"
  And I should see the subject "Math"


Scenario: Edit a subject
  Given the subject "Math" exists
  And the subject "English" exists
  When I am on the subjects page

  When I change the subject "Math" to "Changed"
  Then I should not see the subject "Math"
  And I should see the subject "Changed"

  When I am on the subjects page
  Then I should not see the subject "Math"
  Then I should see the subject "English"
  And I should see the subject "Changed"


Scenario: Add a subject
  Given the subject "Math" exists
  And the subject "English" exists
  When I am on the subjects page

  When I add the subject "New subject"
  Then I should see the subject "New subject"

  When I am on the subjects page
  Then I should see the subject "Math"
  Then I should see the subject "English"
  Then I should see the subject "New subject"


Scenario: Add and then delete a subject
  Given the subject "Math" exists
  And the subject "English" exists
  When I am on the subjects page

  When I add the subject "New subject"
  Then I should see the subject "New subject"
  When I delete the subject "New subject"
  Then I should not see the subject "New subject"

  When I am on the subjects page
  Then I should not see the subject "New subject"