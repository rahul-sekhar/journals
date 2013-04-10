Then /^the selected page should be (\d+)$/ do |p_page|
  page.should have_css('#pagination .current', text: p_page)
end

Then /^the pages (\d+)\-(\d+) should be visible$/ do |p_from, p_to|
  within '#pagination' do
    page.should have_no_content (p_from.to_i - 1).to_s
    (p_from..p_to).each do |page_no|
      page.should have_content page_no
    end
    page.should have_no_content (p_to.to_i + 1).to_s
  end
end

When /^I select page (\d+)$/ do |p_page|
  page.find('#pagination a', text: p_page).click
end
