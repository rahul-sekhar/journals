@current
Feature: Create a post

As a user I should be able to create a post so that I can add content to the site

Scenario: Create a minimal post with a title, content and tags
Given I have logged in as a teacher "Rahul Sekhar"
And I am on the create post page
And I fill in "Title" with "Test Post"
And I fill in "Content" with "<p>Some <em>HTML</em> content</p>"
And I fill in "Tags" with "Test posts, Minimal"
And I click "Create post"
Then a minimal test post should exist