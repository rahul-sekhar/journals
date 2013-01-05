Given /^a post about an ice cream factory visit exists$/ do
  @post = shalini.user.posts.build(
    title: 'Ice cream factory visit',
    content: 'The whole school went to the Daily Dairy factory for a visit. It was a very small factory and a quick quick quick visit...'
  )
  @post.created_at = Date.new(2012, 10, 25)
  @post.save!
end

Given /^a post about an ice cream factory visit with extended information exists$/ do
  step 'a post about an ice cream factory visit exists'
  @post = Post.find_by_title('Ice cream factory visit')

  @post.update_attributes!(
    tag_names: "icecream, visits",
    teacher_ids: [angela.id, aditya.id],
    student_ids: [ansh.id, sahana.id]
  )
end

Then /^a minimal test post should exist$/ do
  post = Post.where(title: "Test Post").first
  post.should be_present

  Tag.find_by_name("Test posts").should be_present
  Tag.find_by_name("Minimal").should be_present
  
  post.content.should == "<p>Some <em>HTML</em> content</p>"
  post.tags.map{ |tag| tag.name }.should =~ ["Test posts", "Minimal"]
  post.author_name.should == "Rahul"
end

Then /^a post with student and teacher tags should exist$/ do
  post = Post.where(title: "Tagged Post").first
  post.should be_present

  post.students.should =~ [ansh, sahana]
  post.teachers.should =~ [Teacher.find_by_name("Rahul", "Sekhar"), angela]
end

Then /^a post with permissions should exist$/ do
  post = Post.where(title: "Permissions Post").first
  post.should be_present

  post.visible_to_guardians.should == true
  post.visible_to_students.should == false
end

Then /^a student post with student and teacher tags should exist$/ do
  post = Post.where(title: "Tagged Student Post").first
  post.should be_present

  post.students.should =~ [ansh, Student.find_by_name("Rahul", "Sekhar")]
  post.teachers.should =~ [angela]
end

Then /^a guardian post with student and teacher tags should exist$/ do
  post = Post.where(title: "Tagged Guardian Post").first
  post.should be_present

  post.students.should =~ [ansh, Student.find_by_name("Roly", "Sekhar")]
  post.teachers.should =~ [angela]
end

Then /^a guardian post with permissions should exist$/ do
  post = Post.where(title: "Guardian Permissions Post").first
  post.should be_present

  post.visible_to_guardians.should == true
  post.visible_to_students.should == true
end
