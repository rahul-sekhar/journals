json.(comment, :id, :author_id, :author_type, :content)

json.created_at comment.formatted_created_at

json.editable can?(:update, comment)