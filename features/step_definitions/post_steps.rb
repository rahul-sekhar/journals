Then /^I should see the post "(.*?)"$/ do |p_name|
  page.should have_css(".post h3", text: /#{Regexp.escape(p_name)}/, visible: true)
end

Then /^I should not see the post "(.*?)"$/ do |p_name|
  page.should have_no_css(".post h3", text: /#{Regexp.escape(p_name)}/, visible: true)
end

When /^I look at the post "(.*?)"$/ do |p_name|
  @viewing = page.find(".post h3", text: /#{Regexp.escape(p_name)}/, visible: true).
    first(:xpath, ".//..")
end

Then(/^(.*) in the posts (\S*)$/) do |p_step, p_section|
  within @viewing.find(".#{p_section}") do
    step p_step
  end
end

Then(/^its restriction should be "(.*?)"$/) do |p_text|
  restrictions = @viewing.find('.restrictions', visible: true)
  restrictions[:title].should eq(p_text)
end

Then(/^it should have no restrictions$/) do
  @viewing.should have_no_css('.restrictions', visible: true)
end

When(/^I tag the (student|teacher) "(.*?)" in the post$/) do |p_type, p_name|
  within ".people-tags .#{p_type}s" do
    click_on "Add #{p_type}" if page.has_no_css?('.container', text: /.+/, visible: true)
    page.should have_css('.container', text: /.+/, visible: true)
    page.find('.container').click_on p_name
  end
end

When(/^I untag the (student|teacher) "(.*?)" in the post$/) do |p_type, p_name|
  within ".people-tags .#{p_type}s" do
    page.find('.tag-list li', text: p_name).find('.remove').click
  end
end

When(/^I look at the (student|teacher) tags section$/) do |p_type|
  @viewing = page.find(".people-tags .#{p_type}s")
end

Given /^a post titled "(.*?)" created by me exists$/ do |p_title|
  @post = FactoryGirl.build(:post, title: p_title, author: @profile)
  @post.initialize_tags
  @post.save!
end

Given /^a post titled "(.*?)" created by a (student|teacher|guardian) exists$/ do |p_title, p_type|
  profile = FactoryGirl.create(p_type)
  @post = FactoryGirl.build(:post, title: p_title, author: profile)
  @post.initialize_tags
  @post.save!
end

Given /^that post has the students? "(.*?)" tagged$/ do |p_student_names|
  p_student_names.split(",").each do |student_name|
    student = Student.where(first_name: student_name).first

    @post.students << student
  end
end

Given /^that post is (visible|not visible) to guardians$/ do |p_visible|
  @post.visible_to_guardians = (p_visible == "visible")
  @post.save
end

Given /^that post is (visible|not visible) to students$/ do |p_visible|
  @post.visible_to_students = (p_visible == "visible")
  @post.save
end


# Student observations
Then(/^I should see "(.*?)" in the student observation buttons$/) do |p_content|
  page.find('#observation-buttons').should have_content p_content
end

When(/^I fill in the observation for "(.*?)" with "(.*?)"$/) do |p_name, p_text|
  page.find('#observation-buttons').click_on p_name
  step 'I fill in the "Student Observation" editor with "' + p_text +'"'
end
