module NavigationHelpers
  def path_to(page_name)
    case page_name

    when /the home page/
      '/'

    when /the posts page/
      posts_path

    when /the create post page/
      new_post_path

    when /the login page/
      login_path

    when /the page for that post/
      post_path(@post)

    when /the edit page for that post/
      edit_post_path(@post)

    when /the edit page for that comment/
      edit_post_comment_path(@comment.post, @comment)

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)