Given /^I am on (.*?)$/ do |p_page|
  visit path_to(p_page)
end

Then /^I should be on (.*?)$/ do |p_page|
  current_path.should == path_to(p_page)
end

Then /^I should see "(.*?)"$/ do |p_content|
  page.should have_content p_content
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
