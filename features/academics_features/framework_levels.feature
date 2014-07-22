Feature: Edit a framework with custom levels

Background:
  Given the subject "Geography" exists with a framework
  And the subject "English" exists with a framework
  And the subject "English" has the column name "Step"
  And the subject "Math" exists with a framework
  And the subject "Math" has the column name "Region"
  And the subject "Math" has no level numbers

Scenario: Change custom levels
  Given I have logged in as the teacher Rahul
  When I am on the subjects page
  And I edit the framework for the subject "Geography"
  Then I should see "Framework | Geography"
  And I should see "Some milestone"
  And the first level heading should be "level 1"
  And the second level heading should be "level 2"

  When I change the column name to "phase" and disable level numbers
  Then the first level heading should be "phase"
  And the second level heading should be "phase"

  When I am on the subjects page
  And I edit the framework for the subject "Geography"
  Then I should see "Framework | Geography"
  And I should see "Some milestone"
  Then the first level heading should be "phase"
  And the second level heading should be "phase"

Scenario: Edit frameworks
  Given I have logged in as the teacher Rahul
  When I am on the subjects page
  And I edit the framework for the subject "Geography"
  Then I should see "Framework | Geography"
  And I should see "Some milestone"
  And the first level heading should be "level 1"
  And the second level heading should be "level 2"

  Then I close the framework
  And I edit the framework for the subject "English"
  Then I should see "Framework | English"
  And I should see "Some milestone"
  And the first level heading should be "step 1"
  And the second level heading should be "step 2"

  Then I close the framework
  And I edit the framework for the subject "Math"
  Then I should see "Framework | Math"
  And I should see "Some milestone"
  And the first level heading should be "region"
  And the second level heading should be "region"


Scenario: View framework
  Given I have logged in as the guardian Rahul
  And my student Roly has the subject "Math"
  When I go to the work page
  And I select "Roly" from the students menu
  And I select "Math" from the subjects menu
  Then the subjects menu should have "Math" selected
  And I click "View framework"
  Then I should see "Framework | Math"
  And I should see "Some milestone"
  And the first level heading should be "region"
  And the second level heading should be "region"