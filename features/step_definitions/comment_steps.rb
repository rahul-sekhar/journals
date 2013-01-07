Given /^that post has a comment "(.*?)", dated "(.*?)", posted by the (student|teacher|guardian) "(.*?)"$/ do |p_content, p_date, p_type, p_author|
  
  klass = p_type.capitalize.constantize
  author = klass.find_by_first_name!(p_author)
  
  @comment = @post.comments.build(content: p_content)
  @comment.author = author
  @comment.created_at = Date.strptime(p_date, '%d/%m/%Y')
  @comment.save!
end

Given /^that post has a comment "(.*?)", posted by a (student|teacher|guardian)$/ do |p_content, p_type|
  
  @comment = @post.comments.build(content: p_content)
  @comment.author = FactoryGirl.create(p_type)
  @comment.save!
end

Given /^that post has a comment "(.*?)", posted by me$/ do |p_content|
  @comment = @post.comments.build(content: p_content)
  @comment.author = @logged_in_user.profile
  @comment.save!
end

Then /^that comment should be destroyed$/ do
  Comment.should_not exist(@comment)
end
