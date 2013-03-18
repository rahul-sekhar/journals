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

# Given /^a (student|guardian) post about an ice cream factory visit with extended information exists$/ do |p_type|
#   step 'a post about an ice cream factory visit with extended information exists'

#   @post.author = FactoryGirl.create(p_type)
#   @post.initialize_tags
#   @post.save!
# end

# Given /^a post about an ice cream factory visit with student observations exists$/ do
#   step 'a post about an ice cream factory visit with extended information exists'

#   @post.student_observations.create!(student_id: sahana.id, content: "Some observations about Sahana")
#   @post.save!
# end

def shalini
  create_profile('teacher', 'Shalini Sekhar')
end

def angela
  create_profile('teacher', 'Angela Jain')
end

def aditya
  create_profile('teacher', 'Aditya Pandya')
end

def ansh
  create_profile('student', 'Ansh Prasad')
end

def sahana
  create_profile('student', 'Sahana Joshi')
end