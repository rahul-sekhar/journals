Given /^that post has a comment "(.*?)", dated "(.*?)", posted by the (student|teacher|guardian) "(.*?)"$/ do |p_content, p_date, p_type, p_author|
  
  user_klass = p_type.capitalize.constantize
  user = user_klass.find_by_first_name!(p_author).user
  
  @comment = @post.comments.build(content: p_content)
  @comment.user = user
  @comment.created_at = Date.strptime(p_date, '%d/%m/%Y')
  @comment.save!
end

Given /^that post has a comment "(.*?)", posted by a (student|teacher|guardian)$/ do |p_content, p_type|
  
  @comment = @post.comments.build(content: p_content)
  @comment.user = FactoryGirl.create(p_type).user
  @comment.save!
end

Given /^that post has a comment "(.*?)", posted by me$/ do |p_content|
  @comment = @post.comments.build(content: p_content)
  @comment.user = @logged_in_user
  @comment.save!
end

Then /^that comment should be destroyed$/ do
  Comment.should_not exist(@comment)
end
