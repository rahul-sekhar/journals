Given /^a post about an ice cream factory visit exists$/ do
  user = create_profile("teacher", "Shalini Sekhar").user
  
  post = user.posts.build(
    title: 'Ice cream factory visit',
    content: 'The whole school went to the Daily Dairy factory for a visit. It was a very small factory and a quick quick quick visit...'
  )
  post.created_at = Date.new(2012, 10, 25)
  post.save!
end

Given /^a post about an ice cream factory visit with extended information exists$/ do
  step 'a post about an ice cream factory visit exists'
  post = Post.find_by_title('Ice cream factory visit')
  
  angela = create_profile("teacher", "Angela Jain")
  aditya = create_profile("teacher", "Aditya Pandya")

  john = create_profile("student", "John Doe")
  tim = create_profile("student", "Tim McDonald")

  post.update_attributes!(
    tag_names: "icecream, visits",
    teacher_ids: [angela.id, aditya.id],
    student_ids: [john.id, tim.id]
  )
end