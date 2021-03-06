# Steps in a particular block set through another step
Then /^(.*?) in it$/ do |p_step|
  within @viewing do
    step p_step
  end
end


# Page testing steps
Given /^I am on (.*?)$/ do |p_page|
  visit path_to(p_page)
end

When /^I go to (.*?)$/ do |p_page|
  visit path_to(p_page)
end

Then /^I should be on (.*?)$/ do |p_page|
  current_path.should == path_to(p_page)
end

Then /^the page heading should be "(.*?)"$/ do |p_heading|
  page.should have_css "h2", text: p_heading
end


# Content testing steps
Then /^I should see "(.*?)"$/ do |p_content|
  page.should have_content p_content
end

Then /^I should not see "(.*?)"$/ do |p_content|
  page.should have_no_content p_content
end


# Input steps
When /^I fill in "(.*?)" with "(.*?)"$/ do |p_field, p_value|
  fill_in p_field, with: p_value
end

When(/^I fill in the "(.*?)" editor with "(.*?)"$/) do |p_field, p_text|
  label = page.find('label', text: p_field, visible: false)
  id = label['for']
  field = find("##{id}", visible: false)

  page.execute_script('$("#' + field[:id]  + '").tinymce().setContent("' + p_text + '")')
end

Then /^"(.*?)" should be filled in with "(.*?)"$/ do |p_field, p_value|
  find_field(p_field).value.should == p_value
end

Then(/^the "(.*?)" editor should be filled in with "(.*?)"$/) do |p_field, p_text|
  label = page.find('label', text: p_field, visible: false)
  id = label['for']
  field = find("##{id}", visible: false)

  text = page.evaluate_script('$("#' + field[:id]  + '").tinymce().getContent()')
  text.should eq(p_text)
end


When /^I check the checkbox "(.*?)"$/ do |p_checkbox|
  page.check(p_checkbox)
end

Then /^the checkbox "(.*?)" should be checked$/ do |p_checkbox|
  find_field(p_checkbox).should be_checked
end

Then /^the checkbox "(.*?)" should be unchecked$/ do |p_checkbox|
  find_field(p_checkbox).should_not be_checked
end


# Link and button steps
When /^I click "(.*?)"$/ do |p_link|
  click_on p_link
end

When /^I click the (\S*) link$/ do |p_link|
  page.should have_css "a.#{p_link}"
  page.find("a.#{p_link}").click
end

Then /^I should see a (\S*) link$/ do |p_link|
  page.should have_css("a.#{p_link}", visible: true)
end

Then /^I should not see a (\S*) link$/ do |p_link|
  page.should have_no_css("a.#{p_link}", visible: true)
end

# Option steps
Then /^I should see an option containing "(.*?)"$/ do |p_option|
  page.should have_field p_option, type: 'radio'
end

When /^I select the option containing "(.*?)"$/ do |p_option|
  page.choose p_option
end


# Error
Then /^I should see an error$/ do
  page.should have_css('#notifications .error', visible: true)
end

Then /^I should not see an error$/ do
  page.should have_no_css('#notifications .error', visible: true)
end


# General internal functions
def blur_input_inside(node)
  script = "$('input:visible, textarea:visible').blur();"
  page.execute_script(script)
  node.should have_css('input, textarea', visible: false)
end

def fill_input_inside(node, value)
  node.find('input, textarea', visible: true).set(value)
  blur_input_inside node
end
