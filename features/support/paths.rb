module NavigationHelpers
  def path_to(page_name)
    case page_name

    when /the home page/
      '/'

    when /the page for that post/
      post_path(@post)

    when /the edit page for that post/
      edit_post_path(@post)

    when /the page for that profile/
      profile_path(@profile)

    when /the page for my profile/
      profile_path(@logged_in_profile)

    when /the page for my student/
      profile_path(@logged_in_profile.students.first)

    when /the page for the guardian/
      profile_path(@guardian)

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
end

World(NavigationHelpers)