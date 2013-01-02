Given /^a post about an ice cream factory visit exists$/ do
  step 'a teacher profile "Shalini Sekhar" with the password "pass" exists'
  user = TeacherProfile.find_by_name("Shalini", "Sekhar").user
  post = user.posts.build(
    title: "Ice cream factory visit",
    content: "The whole school went to the Daily Dairy factory for a visit. It was a very small factory and a quick quick quick visit..."
  )
  post.created_at = Date.new(2012, 10, 25)
  post.save!
end