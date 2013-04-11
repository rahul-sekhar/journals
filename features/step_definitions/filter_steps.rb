Then /^(.*?) in the filter bar$/ do |p_step|
  within '#upper-bar' do
    step p_step
  end
end

When /^I search for "(.*?)"$/ do |p_text|
  fill_in 'search', with: p_text
end

Then /^I should not see the search bar$/ do
  page.should have_no_field('search', visible: true)
end
