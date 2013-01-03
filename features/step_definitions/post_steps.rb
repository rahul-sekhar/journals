Given /^a post about an ice cream factory visit exists$/ do
  shalini = Teacher.create!(first_name: "Shalini", last_name: "Sekhar", password: "pass")
  user = shalini.user
  
  post = user.posts.build(
    title: "Ice cream factory visit",
    content: "The whole school went to the Daily Dairy factory for a visit. It was a very small factory and a quick quick quick visit..."
  )
  post.created_at = Date.new(2012, 10, 25)
  post.save!
end

  # angela = Teacher.create!(first_name: "Angela", last_name: "Jain", password: "pass")
  # aditya = Teacher.create!(first_name: "Aditya", last_name: "Pandya", password: "pass")
  #   tag_names: "icecream, visits",
  #   teacher_ids: [angela.id, aditya.id]