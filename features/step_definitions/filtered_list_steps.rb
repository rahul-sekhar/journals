Given /^I should see its add (\S*) list$/ do |p_list|
  @list = @viewing.should have_css(".#{p_list}s .filtered-list", visible: true)
end

Given /^I should not see its add (\S*) list$/ do |p_list|
  @list = @viewing.should have_no_css(".#{p_list}s .filtered-list", visible: true)
end

Given /^get its add (\S*) list$/ do |p_list|
  @list = @viewing.find(".#{p_list}s .filtered-list", visible: true)
end

When /^I open (.*) list$/ do |p_list|
  step "get #{p_list} list"
  button = @list.find('.add')
  button.text.should match(/^add/i)
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
