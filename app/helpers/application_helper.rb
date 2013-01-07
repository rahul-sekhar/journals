module ApplicationHelper
  def title(page_title, set_heading = true)
    content_for(:title, page_title)
    content_for(:heading, page_title) if set_heading
  end

  def page_heading(heading)
    content_for(:heading, heading)
  end

  def page_id(id)
    content_for(:page_id, id)
  end

  def page_title
    if content_for(:title).present?
      "Journals Demo - #{content_for(:title)}"
    else
      "Journals Demo"
    end
  end

  def profile_name(profile, long=false)
    display_name = long ? profile.full_name : profile.name

    link_to display_name, url_for(profile), title: profile.name_with_type 
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
