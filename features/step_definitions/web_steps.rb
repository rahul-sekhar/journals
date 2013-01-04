Given /^I am on (.*?)$/ do |p_page|
  visit path_to(p_page)
end

Then /^I should be on (.*?)$/ do |p_page|
  current_path.should == path_to(p_page)
end

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

Then /^a "(.*?)" block should not be present$/ do |p_css|
  page.should have_no_css p_css
end

When /^I fill in "(.*?)" with "(.*?)"$/ do |p_field, p_value|
  fill_in p_field, with: p_value
end

When /^I click "(.*?)"$/ do |p_link|
  click_on p_link
end

When /^I select "(.*?)" from "(.*?)"$/ do |p_option, p_select|
  page.select p_option, from: p_select
end

When /^I unselect "(.*?)" from "(.*?)"$/ do |p_option, p_select|
  page.unselect p_option, from: p_select
end

Then /^the checkbox "(.*?)" should be unchecked$/ do |p_checkbox|
  page.find_field(p_checkbox).should_not be_checked
end

When /^I check the checkbox "(.*?)"$/ do |p_checkbox|
  page.check(p_checkbox)
end
