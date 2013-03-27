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

Then(/^I should see "(.*?)" in its (\S*)$/) do |p_content, p_section|
  within @viewing.find(".#{p_section}") do
    page.should have_content p_content
  end
end

Then(/^its restriction should be "(.*?)"$/) do |p_text|
  restrictions = @viewing.find('.restrictions', visible: true)
  restrictions[:title].should eq(p_text)
end


# Then /^that post should be destroyed$/ do
#   Post.should_not exist(@post)
# end

# Given /^a post titled "(.*?)" created by me exists$/ do |p_title|
#   @post = FactoryGirl.build(:post, title: p_title, author: @logged_in_user.profile)
#   @post.initialize_tags
#   @post.save!
# end

# Given /^a post titled "(.*?)" created by a (student|teacher|guardian) exists$/ do |p_title, p_type|
#   profile = FactoryGirl.create(p_type)
#   @post = FactoryGirl.build(:post, title: p_title, author: profile)
#   @post.initialize_tags
#   @post.save!
# end

# Given /^that post has the students? "(.*?)" tagged$/ do |p_student_names|
#   p_student_names.split(",").each do |student_name|
#     first_name, last_name = split_name(student_name)
#     student = Student.where(first_name: first_name, last_name: last_name).first

#     @post.students << student
#   end
# end

# Given /^that post is (visible|not visible) to guardians$/ do |p_visible|
#   @post.visible_to_guardians = (p_visible == "visible")
#   @post.save
# end

# Given /^that post is (visible|not visible) to students$/ do |p_visible|
#   @post.visible_to_students = (p_visible == "visible")
#   @post.save
# end



# # Testing of the existence of specific posts
# Then /^a minimal test post should exist$/ do
#   @post = Post.where(title: "Test Post").first
#   @post.should be_present

#   Tag.find_by_name("Test posts").should be_present
#   Tag.find_by_name("Minimal").should be_present

#   @post.content.should == "<p>Some <em>HTML</em> content</p>"
#   @post.tags.map{ |tag| tag.name }.should =~ ["Test posts", "Minimal"]
#   @post.author.name.should == "Rahul Sekhar"
# end

# Then /^a post with student and teacher tags should exist$/ do
#   @post = Post.where(title: "Tagged Post").first
#   @post.should be_present

#   @post.students.should =~ [ansh, sahana]
#   @post.teachers.should =~ [Teacher.where(first_name:"Rahul").first, angela]
# end

# Then /^a post with permissions should exist$/ do
#   @post = Post.where(title: "Permissions Post").first
#   @post.should be_present

#   @post.visible_to_guardians.should == true
#   @post.visible_to_students.should == false
# end

# Then /^a student post with student and teacher tags should exist$/ do
#   @post = Post.where(title: "Tagged Student Post").first
#   @post.should be_present

#   @post.students.should =~ [ansh, Student.where(first_name: "Rahul").first]
#   @post.teachers.should =~ [angela]
# end

# Then /^a guardian post with student and teacher tags should exist$/ do
#   @post = Post.where(title: "Tagged Guardian Post").first
#   @post.should be_present

#   @post.students.should =~ [ansh, Student.where(first_name: "Roly").first]
#   @post.teachers.should =~ [angela]
# end

# Then /^a guardian post with permissions should exist$/ do
#   @post = Post.where(title: "Guardian Permissions Post").first
#   @post.should be_present

#   @post.visible_to_guardians.should == true
#   @post.visible_to_students.should == true
# end

# Then /^a guardian post with lucky should exist$/ do
#   @post = Post.where(title: "Guardian Post with Lucky").first
#   @post.should be_present

#   @post.students.should == [Student.where(first_name: "Lucky").first]
# end
