Feature: View all posts on the home page

As a user I should be able to view all posts visible to me on my home page, sorted by their date so that I can quickly see recently added posts

@current
Scenario: View a post
Given a post about an ice cream factory visit exists
And I have logged in as a teacher, "Rahul Sekhar"
And I am on the posts page
Then I should see "Viewing posts"
And I should see "Ice cream factory visit"
And I should see "The whole school went to the Daily Dairy"
And I should see "25th October 2012"
And I should see "Posted by Shalini"