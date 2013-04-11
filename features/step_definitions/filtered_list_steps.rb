Given /^I should see its add group list$/ do
  @list = @viewing.should have_css('.groups .filtered-list', visible: true)
end

Given /^I should see its add mentor list$/ do
  @list = @viewing.should have_css('.mentors .filtered-list', visible: true)
end

Given /^I should see its add mentee list$/ do
  @list = @viewing.should have_css('.mentees .filtered-list', visible: true)
end


Given /^I should not see its add group list$/ do
  @list = @viewing.should have_no_css('.groups .filtered-list', visible: true)
end

Given /^I should not see its add mentor list$/ do
  @list = @viewing.should have_no_css('.mentors .filtered-list', visible: true)
end

Given /^I should not see its add mentee list$/ do
  @list = @viewing.should have_no_css('.mentees .filtered-list', visible: true)
end


Given /^get its add group list$/ do
  @list = @viewing.find('.groups .filtered-list', visible: true)
end

Given /^get its add mentor list$/ do
  @list = @viewing.find('.mentors .filtered-list', visible: true)
end

Given /^get its add mentee list$/ do
  @list = @viewing.find('.mentees .filtered-list', visible: true)
end

When /^I open (.*) list$/ do |p_list|
  step "get #{p_list} list"
  button = @list.find('.add')
  button.text.should eq('add')
  button.click
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
