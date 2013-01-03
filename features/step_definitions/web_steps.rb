Given /^I am on (.*?)$/ do |page|
  visit path_to(page)
end

Then /^I should be on (.*?)$/ do |page|
  current_path.should == path_to(page)
end

Then /^I should see "(.*?)"$/ do |content|
  page.should have_content content
end

Then /^I should see "(.*?)" within the "(.*?)" block$/ do |content, context|
  within(context) do
    page.should have_content content
  end
end

When /^I fill in "(.*?)" with "(.*?)"$/ do |field, value|
  fill_in field, with: value
end

When /^I click "(.*?)"$/ do |link|
  click_on link
end
