json.(post, :id, :title, :content, :author_id, :author_type, :student_ids, :teacher_ids)
json.(post, :visible_to_students, :visible_to_guardians, :tag_names, :student_observations)

json.comments post.comments.each do |comment|
  json.partial! "comments/comment", comment:comment
end

json.created_at post.formatted_created_at

json.editable can?(:update, post)
