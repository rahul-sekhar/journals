Given /^a comment on the post "(.*?)" exists with content "(.*?)", date "(.*?)", posted by the (student|teacher|guardian) "(.*?)"$/ do |p_post_title, p_content, p_date, p_type, p_author|
  
  post = Post.find_by_title!(p_post_title)
  user_klass = p_type.capitalize.constantize
  user = user_klass.find_by_first_name!(p_author).user
  
  @comment = post.comments.build(user: user, content: p_content)
  @comment.created_at = Date.strptime(p_date, '%d/%m/%Y')
  @comment.save!
end