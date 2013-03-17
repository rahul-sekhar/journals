json.(post, :id, :title, :content, :author_id, :author_type, :student_ids, :teacher_ids)

json.created_at post.formatted_created_at

json.editable can?(:update, post)
