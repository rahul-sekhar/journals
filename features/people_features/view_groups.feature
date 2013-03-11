@angular
Feature: View groups through the people filters

Background:
  Given I have logged in as the teacher Rahul
  And a student "Roly Sekhar" exists
  And that student belongs to the groups "Dogs, Puppies"
  And a student "Jumble Dog" exists
  And that student belongs to the groups "Dogs"
  And a student "Lucky Sekhar" exists
  And that student belongs to the groups "Dogs"
  And a student "John Doe" exists
  And a group "Empty" exists

Scenario: View empty group
  When I am on the people page
  Then the viewing menu should have the option "Dogs"
  And the viewing menu should have the option "Puppies"
  And the viewing menu should have the option "Empty"

  When I select "Empty" from the viewing menu
  Then the viewing menu should have "Empty" selected
  And the viewing menu should have the option "Dogs"
  And the viewing menu should have the option "Puppies"
  And the viewing menu should not have the option "Empty"
  
  And I should see "No matching people were found"
  And I should not see a profile for "Roly Sekhar"
  And I should not see a profile for "Lucky Sekhar"
  And I should not see a profile for "Jumble Dog"
  And I should not see a profile for "John Doe"

Scenario: View groups with students
  When I am on the people page
  And I select "Dogs" from the viewing menu
  Then the viewing menu should have "Dogs" selected
  And I should see a profile for "Roly Sekhar"
  And I should see a profile for "Lucky Sekhar"
  And I should see a profile for "Jumble Dog"
  And I should not see a profile for "John Doe"

  When I select "Puppies" from the viewing menu
  Then the viewing menu should have "Puppies" selected
  And I should not see a profile for "Lucky Sekhar"
  And I should not see a profile for "Jumble Dog"
  And I should not see a profile for "John Doe"
  And I should see a profile for "Roly Sekhar"