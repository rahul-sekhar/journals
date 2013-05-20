Feature: Edit a framework

Background:
  Given I have logged in as the teacher Rahul


@current
Scenario: Edit a framework
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

  When I change the milestone "Some milestone" to "Changed milestone"
  Then I should see the milestone "Changed milestone" under "Child" in level 1
  Then I should not see the milestone "Some milestone" under "Child" in level 1

  When I add the milestone "New milestone" to "Child" in level 3
  Then I should see the milestone "New milestone" under "Child" in level 3

  When I add the milestone "Another milestone" to "Child" in level 1
  Then I should see the milestone "Another milestone" under "Child" in level 1
  And I should see the milestone "Changed milestone" under "Child" in level 1
  And I should see the milestone "Another one" under "Child" in level 1

  When I delete the milestone "Another milestone"
  Then I should not see the milestone "Another milestone" under "Child" in level 1
  And I should see the milestone "Changed milestone" under "Child" in level 1
  And I should see the milestone "Another one" under "Child" in level 1

  When I delete the milestone "Third"
  Then I should not see the milestone "Third" under "Child" in level 2

  When I change the strand "Child" to "Changed Child"
  Then I should not see the strand "Child" under "Counting"
  And I should see the strand "Changed Child" under "Counting"

  When I delete the strand "Numbers"
  Then I should not see the root strand "Numbers"
  Then I should see the root strand "Geometry"
  And I should not see "Counting"
  And I should not see "Child"
  And I should not see "Adding"
  And I should not see "Some milestone"
  And I should not see "Another one"
  And I should not see "Middle milestone"

  When I add the root strand "New strand"
  Then I should see the root strand "New strand"
  And I should see "Done"

  When I add the strand "Substrand" to "New strand"
  Then I should see the strand "Substrand" under "New strand"
  And I should see "Done"