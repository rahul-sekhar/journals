# General post things
Then /^that post should be destroyed$/ do
  Post.should_not exist(@post)
end

Given /^a post titled "(.*?)" created by me exists$/ do |p_title|
  @post = FactoryGirl.build(:post, title: p_title, author: @logged_in_user.profile)
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
    first_name, last_name = split_name(student_name)
    student = Student.find_by_name(first_name, last_name)

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


# Creation of specific posts
Given /^a post about an ice cream factory visit exists$/ do
  @post = shalini.posts.build(
    title: 'Ice cream factory visit',
    content: 'The whole school went to the Daily Dairy factory for a visit. It was a very small factory and a quick quick quick visit...'
  )
  @post.created_at = Date.new(2012, 10, 25)
  @post.save!
end

Given /^a post about an ice cream factory visit with extended information exists$/ do
  step 'a post about an ice cream factory visit exists'

  @post.update_attributes!(
    tag_names: "icecream, visits",
    teacher_ids: [angela.id, aditya.id],
    student_ids: [ansh.id, sahana.id],
    visible_to_students: true
  )
end

Given /^a (student|guardian) post about an ice cream factory visit with extended information exists$/ do |p_type|
  step 'a post about an ice cream factory visit with extended information exists'

  @post.author = FactoryGirl.create(p_type)
  @post.initialize_tags
  @post.save!
end

Given /^a post about an ice cream factory visit with student observations exists$/ do
  step 'a post about an ice cream factory visit with extended information exists'

  @post.student_observations.create!(student_id: sahana.id, content: "Some observations about Sahana")
  @post.save!
end


# Testing of the existence of specific posts
Then /^a minimal test post should exist$/ do
  @post = Post.where(title: "Test Post").first
  @post.should be_present

  Tag.find_by_name("Test posts").should be_present
  Tag.find_by_name("Minimal").should be_present
  
  @post.content.should == "<p>Some <em>HTML</em> content</p>"
  @post.tags.map{ |tag| tag.name }.should =~ ["Test posts", "Minimal"]
  @post.author.full_name.should == "Rahul Sekhar"
end

Then /^a post with student and teacher tags should exist$/ do
  @post = Post.where(title: "Tagged Post").first
  @post.should be_present

  @post.students.should =~ [ansh, sahana]
  @post.teachers.should =~ [Teacher.find_by_name("Rahul", "Sekhar"), angela]
end

Then /^a post with permissions should exist$/ do
  @post = Post.where(title: "Permissions Post").first
  @post.should be_present

  @post.visible_to_guardians.should == true
  @post.visible_to_students.should == false
end

Then /^a student post with student and teacher tags should exist$/ do
  @post = Post.where(title: "Tagged Student Post").first
  @post.should be_present

  @post.students.should =~ [ansh, Student.find_by_name("Rahul", "Sekhar")]
  @post.teachers.should =~ [angela]
end

Then /^a guardian post with student and teacher tags should exist$/ do
  @post = Post.where(title: "Tagged Guardian Post").first
  @post.should be_present

  @post.students.should =~ [ansh, Student.find_by_name("Roly", "Sekhar")]
  @post.teachers.should =~ [angela]
end

Then /^a guardian post with permissions should exist$/ do
  @post = Post.where(title: "Guardian Permissions Post").first
  @post.should be_present

  @post.visible_to_guardians.should == true
  @post.visible_to_students.should == true
end

Then /^a guardian post with lucky should exist$/ do
  @post = Post.where(title: "Guardian Post with Lucky").first
  @post.should be_present

  @post.students.should == [Student.find_by_name("Lucky", "Sekhar")]
end
