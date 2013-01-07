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

    when /the page for that profile/
      profile_path(@profile)

    when /the page for my profile/
      profile_path(@logged_in_user.profile)

    when /the page for the guardian/
      profile_path(@guardian)

    when /the edit page for that profile/
      edit_profile_path(@profile)

    when /the edit page for the guardian/
      edit_profile_path(@guardian)

    when /the page for one of the students/
      student_path(@student)

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

  def profile_path(profile)
    if profile.is_a? Student
      student_path(profile)
    elsif profile.is_a? Teacher
      teacher_path(profile)
    elsif profile.is_a? Guardian
      guardian_path(profile)
    end
  end

  def edit_profile_path(profile)
    if profile.is_a? Student
      edit_student_path(profile)
    elsif profile.is_a? Teacher
      edit_teacher_path(profile)
    elsif profile.is_a? Guardian
      edit_guardian_path(profile)
    end
  end
end

World(NavigationHelpers)