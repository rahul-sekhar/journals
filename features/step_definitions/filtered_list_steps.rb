Given /^get its add group list$/ do
  @list = @viewing.find('.groups .filtered-list', visible: true)
  button = @list.find('.add')
  button.click if button.text == 'Add'
end

Given /^get its add mentor list$/ do
  @list = @viewing.find('.mentors .filtered-list', visible: true)
  button = @list.find('.add')
  button.click if button.text == 'Add'
end

Given /^get its add mentee list$/ do
  @list = @viewing.find('.mentees .filtered-list', visible: true)
  button = @list.find('.add')
  button.click if button.text == 'Add'
end

When /^I open (.*) list$/ do |p_list|
  step "get #{p_list} list"
end

Then /^(.*) in the list$/ do |p_step|
  within @list do
    step p_step
  end
end

When /^I enter "(.*?)" in (.*) list$/ do |p_value, p_list|
  step "get #{p_list} list"
  @list.find('input').set p_value
end
