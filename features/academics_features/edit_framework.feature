Feature: Edit a framework

Background:
  Given I have logged in as the teacher Rahul


Scenario: Edit a new framework
  Given the subject "Math" exists
  When I am on the subjects page
  And I edit the framework for the subject "Math"
  Then I should see "Framework | Math"

  When I click the close link
  Then I should not see "Framework | Math"

@current
Scenario: Edit an existing framework
  Given the subject "Math" exists with a framework
  When I am on the subjects page
  And I edit the framework for the subject "Math"
  Then I should see "Framework | Math"

  And I should see the root strand "Numbers"
  And I should see the root strand "Geometry"

  And I should see the strand "Counting" under "Numbers"
  And I should see the strand "Child" under "Counting"
  And I should see the strand "Adding" under "Numbers"

  And I should see the milestone "Some milestone" under "Child" in level 1
  And I should see the milestone "Another one" under "Child" in level 1
  And I should see the milestone "Third" under "Child" in level 2

  And I should see the milestone "Middle milestone" under "Adding" in level 2