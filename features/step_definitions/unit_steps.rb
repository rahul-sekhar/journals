When(/^I look at the unit "(.*?)"$/) do |p_unit|
  @viewing = page.find('#units tr', text: /^#{Regexp.escape(p_unit)}/i, visible: true)
end

When /^I change the (\S*) field to "(.*?)"$/ do |p_field, p_value|
  within @viewing do
    field = page.find("td.#{p_field}")
    field.find('.value').click
    fill_input_inside field, p_value
  end
  step 'I should see a notification or error'
end

When /^I change the (\S*) date field to "(.*?)"$/ do |p_field, p_date|
  within @viewing do
    field = page.find("td.#{p_field}")
    field.find('.value').click
    script = "setTimeout(function() {" +
      "$('input:not([name]):visible').datepicker('setDate', '#{p_date}').datepicker('hide');" +
    "}, 10);"
    page.execute_script(script)
  end
  step 'I should see a notification or error'
end

When /^I clear the (\S*) date field$/ do |p_field|
  within @viewing do
    field = page.find("td.#{p_field}")
    field.find('.value').click
    field.find('.clear-date').click
  end
  step 'I should see a notification or error'
end

When /^I add the unit "(.*?)"$/ do |p_name|
  units = page.find('#units')
  units.find('.add').click
  fill_input_inside units, p_name
end

When(/^I delete the unit "(.*?)"$/) do |p_unit|
  unit = page.find('#units tr', text: /^#{Regexp.escape(p_unit)}/i, visible: true)
  unit.click
  unit.should have_css('.delete')
  unit.find('.delete').click
end

Then /^I should not be able to change the (\S*) field$/ do |p_field|
  within @viewing do
    field = page.find("td.#{p_field}")
    field.find('.value').click
    page.should have_no_css('input, textarea', visible: true)
  end
end

Then /^I should not be able to delete the unit$/ do
  within @viewing do
    page.should have_no_css('.delete')
  end
end

Then /^I should not be able to add a unit$/ do
  page.should have_no_css('#units .add')
end