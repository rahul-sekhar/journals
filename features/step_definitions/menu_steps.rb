When /^I open the (\S*) menu$/ do |p_menu|
  page.find(".#{p_menu}.menu, .#{p_menu}.click-menu", visible: true).find('.title').click
end

Then /^I should see the (\S*) menu$/ do |p_menu|
  page.should have_css(".#{p_menu}.menu, .#{p_menu}.click-menu", visible: true)
end

Then /^I should not see the (\S*) menu$/ do |p_menu|
  page.should have_no_css(".#{p_menu}.menu, .#{p_menu}.click-menu", visible: true)
end

Then /^the (\S*) menu should have the option "(.*?)"$/ do |p_menu, p_item|
  within ".#{p_menu}.menu, .#{p_menu}.click-menu" do
    page.find('.title').click
    page.should have_css('li a', text: /^#{Regexp.escape(p_item)}$/i, visible: true)
  end
end

Then /^the (\S*) menu should not have the option "(.*?)"$/ do |p_menu, p_item|
  within ".#{p_menu}.menu, .#{p_menu}.click-menu" do
    page.find('.title').click
    page.should have_css('li a', text:/.+/ , visible: true)
    page.should have_no_css('li a', text: /^#{Regexp.escape(p_item)}$/i, visible: true)
  end
end

Then /^the (\S*) menu should have "(.*?)" selected$/ do |p_menu, p_item|
  within ".#{p_menu}.menu, .#{p_menu}.click-menu" do
    page.should have_css('.title', text: /^#{Regexp.escape(p_item)}$/i)
  end
end

When /^I select "(.*?)" from the (\S*) menu$/ do |p_item, p_menu|
  within ".#{p_menu}.menu, .#{p_menu}.click-menu" do
    page.find('.title').click
    page.find('a', text: /^#{Regexp.escape(p_item)}$/i, visible: true).click
  end
end

