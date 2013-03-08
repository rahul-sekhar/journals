When /^I look at the dialog$/ do
  @viewing = page.first('.dialog, .modal', visible: true)
end

When /^I open the manage groups dialog$/ do
  step 'I select "manage groups" from the add menu'
  step 'I look at the dialog'
end
