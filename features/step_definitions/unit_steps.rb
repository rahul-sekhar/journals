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
  page.find('#units tr', text: /^#{Regexp.escape(p_unit)}/i, visible: true).find('.delete').click
end