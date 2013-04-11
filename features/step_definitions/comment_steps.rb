Given(/^that post has a comment "(.*?)" dated "(.*?)" by the (student|teacher|guardian) "(.*?)"$/) do |p_content, p_date, p_type, p_author|
  klass = p_type.capitalize.constantize
  author = klass.find_by_first_name!(p_author)

  @comment = @post.comments.build(content: p_content)
  @comment.author = author
  @comment.created_at = Date.strptime(p_date, '%d/%m/%Y')
  @comment.save!
end

Given /^that post has a comment "(.*?)" by a (student|teacher|guardian)$/ do |p_content, p_type|
  @comment = @post.comments.build(content: p_content)
  @comment.author = FactoryGirl.create(p_type)
  @comment.save!
end

Given /^that post has a comment "(.*?)" by me$/ do |p_content|
  @comment = @post.comments.build(content: p_content)
  @comment.author = @logged_in_profile
  @comment.save!
end

When /^I fill in the comment editor with "(.*)"$/ do |p_text|
  fill_input_inside(@viewing.find('.comment'), p_text)
end

Then /^the comment editor should be filled with "(.*)"$/ do |p_text|
  @viewing.find('.comment .editor', visible: true).value.should eq(p_text)
end
