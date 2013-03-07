Then /^the selected page should be (\d+)$/ do |p_page|
  page.should have_css('#pagination .current', text: p_page)
end

Then /^the pages (\d+)\-(\d+) should be visible$/ do |p_from, p_to|
  within '#pagination' do
    (p_from..p_to).each do |page|
      page.should have_content page
    end
    page.should have_no_content (p_to.to_i + 1).to_s
  end
end

When /^I select page (\d+)$/ do |p_page|
  page.find('#pagination a', text: p_page).click
end
