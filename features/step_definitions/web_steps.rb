# Step to check within a block
Given /^(.*) within the "(.*?)" block$/ do |p_step, p_context|
  within(p_context) do
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


# Content testing steps
Then /^I should see "(.*?)"$/ do |p_content|
  page.should have_content p_content
end

Then /^I should not see "(.*?)"$/ do |p_content|
  page.should have_no_content p_content
end

Then /^I should see "(.*?)" in a "(.*?)" element$/ do |p_content, p_element|
  page.should have_css p_element, text: /#{p_content}/, visible: true
end

Then /^I should not see "(.*?)" in a "(.*?)" element$/ do |p_content, p_element|
  page.should have_no_css p_element, text: /#{p_content}/, visible: true
end

Then /^a "(.*?)" block should be present$/ do |p_css|
  page.should have_css p_css
end

Then /^a "(.*?)" block should not be present$/ do |p_css|
  page.should have_no_css p_css
end

Then /^the span "(.*?)" should have the title "(.*?)"$/ do |p_text, p_title|
  span = page.find("span", text: p_text)
  span['title'].should == p_title
end

Then /^I should see the heading "(.*?)"$/ do |p_content|
  page.should have_css "h3", text: p_content
end

Then /^I should not see the heading "(.*?)"$/ do |p_content|
  page.should have_no_css "h3", text: p_content
end



# Input field steps
When /^I fill in "(.*?)" with "(.*?)"$/ do |p_field, p_value|
  fill_in p_field, with: p_value
end

Then /^"(.*?)" should be filled in with "(.*?)"$/ do |p_field, p_value|
  find_field(p_field).value.should == p_value
end

Then /^"(.*?)" should be filled in with the lines: (.*?)$/ do |p_field, p_lines|
  p_lines = p_lines[1..-2].split('", "').join("\n")
  find_field(p_field).value.should == p_lines
end

Then /^I should not see the field "(.*?)"$/ do |p_field|
  page.should have_no_field p_field
end


# Option steps
Then /^I should see the option "(.*?)"$/ do |p_option|
  page.should have_field p_option, type: 'radio'
end

When /^I select the option "(.*?)"$/ do |p_option|
  page.choose p_option
end


# Link and button steps
When /^I click "(.*?)"$/ do |p_link|
  click_on p_link
end

When /^I click the element "(.*?)"$/ do |p_element|
  page.first(p_element).click
end

When /^I click the button "(.*?)"$/ do |p_button|
  page.find_button(p_button).click
end

Then /^I should see the button "(.*?)"$/ do |p_button|
  page.should have_button p_button
end

Then /^I should not see the button "(.*?)"$/ do |p_button|
  page.should have_no_button p_button
end

Then /^I should not see the link "(.*?)"$/ do |p_link|
  page.should have_no_link p_link
end

Then /^I should see the link "(.*?)" (\d+) times$/ do |p_content, p_count|
  page.should have_link p_content, count: p_count
end

When /^I click "(.*?)" near "(.*?)" in a list item$/ do |p_link, p_text|
  list_item = page.find('li', text: /#{p_text}/)
  within(list_item) do
    click_on p_link
  end
end

When /^I click "(.*?)" in a "(.*?)" element$/ do |p_text, p_element|
  page.find(p_element, text: /#{p_text}/).click
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

Then /^"(.*?)" should have the options "(.*?)"$/ do |p_select, p_options|
  page.should have_select( p_select, options: p_options.split(",").map{ |option| option.strip } )
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


# Exception testing steps
Then /^I should get a forbidden message when (.*)$/ do |p_step|
  expect{ step p_step }.to raise_exception(CanCan::AccessDenied)
end

Then /^I should get a page not found message when (.*)$/ do |p_step|
  expect{ step p_step }.to raise_exception(ActiveRecord::RecordNotFound)
end


# Text input for in place editing
When /^I enter "(.*?)" in the text input$/ do |p_text|
  page.first('input', visible: true).set p_text

  keypress_script = "$('input:visible').blur();"
  page.execute_script(keypress_script)
end

When /^I enter "(.*?)" in the textarea$/ do |p_text|
  page.first('textarea', visible: true).set p_text
  script = "$('textarea:visible').blur();"
  page.execute_script(script)
end

When /^I enter the date "(.*?)"$/ do |p_date|
  script = "setTimeout(function() {" +
    "$('input:visible').datepicker('setDate', '#{p_date}').datepicker('hide');" + 
  "}, 10);"
  page.execute_script(script)
end

Then /^wait for (\d) seconds$/ do |p_seconds|
  sleep p_seconds.to_i.seconds
end