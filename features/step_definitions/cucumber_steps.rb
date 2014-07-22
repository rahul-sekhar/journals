Given /^PENDING/ do
  pending
end

Then /^show me the page$/ do
  save_and_open_page
end

Then /take a screenshot$/ do
  page.driver.render('cucumber-screenshot.png')
end

Then /^test$/ do
  puts Guardian.all.to_yaml
end