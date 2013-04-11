When /^I close the dialog$/ do
  @viewing.first(:xpath, './/..').find('.ui-dialog-titlebar-close').click
end

When /^I open the manage groups dialog$/ do
  step 'I select "manage groups" from the add menu'
  step 'I look at the dialog'
end

When /^I look at the dialog$/ do
  @viewing = page.first('.dialog, .modal', visible: true)
end
