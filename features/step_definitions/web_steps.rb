# Page testing steps
Given /^I am on (.*?)$/ do |p_page|
  visit path_to(p_page)
end

Then /^I should be on (.*?)$/ do |p_page|
  current_path.should == path_to(p_page)
end


# Content testing steps
Then /^I should see "(.*?)"$/ do |p_content|
  page.should have_content p_content
end

Then /^I should not see "(.*?)"$/ do |p_content|
  page.should have_no_content p_content
end

Then /^I should see "(.*?)" within the "(.*?)" block$/ do |p_content, p_context|
  within(p_context) do
    page.should have_content p_content
  end
end

Then /^I should not see "(.*?)" within the "(.*?)" block$/ do |p_content, p_context|
  within(p_context) do
    page.should have_no_content p_content
  end
end

Then /^a "(.*?)" block should be present$/ do |p_css|
  page.should have_css p_css
end

Then /^a "(.*?)" block should not be present$/ do |p_css|
  page.should have_no_css p_css
end


# Input field steps
When /^I fill in "(.*?)" with "(.*?)"$/ do |p_field, p_value|
  fill_in p_field, with: p_value
end

Then /^"(.*?)" should be filled in with "(.*?)"$/ do |p_field, p_value|
  find_field(p_field).value.should == p_value
end


# Link and button steps
When /^I click "(.*?)"$/ do |p_link|
  click_on p_link
end

When /^I click "(.*?)" within the "(.*?)" block$/ do |p_link, p_context|
  within(p_context) do
    click_on p_link
  end
end


# Select element steps
When /^I select "(.*?)" from "(.*?)"$/ do |p_option, p_select|
  page.select p_option, from: p_select
end

When /^I unselect "(.*?)" from "(.*?)"$/ do |p_option, p_select|
  page.unselect p_option, from: p_select
end

Then /^"(.*?)" should have "(.*?)" selected$/ do |p_select, p_options|
  page.should have_select( p_select, selected: p_options.split(",").map{ |option| option.strip } )
end


# Checkbox steps
Then /^the checkbox "(.*?)" should be checked$/ do |p_checkbox|
  find_field(p_checkbox).should be_checked
end

Then /^the checkbox "(.*?)" should be unchecked$/ do |p_checkbox|
  find_field(p_checkbox).should_not be_checked
end

When /^I check the checkbox "(.*?)"$/ do |p_checkbox|
  page.check(p_checkbox)
end
