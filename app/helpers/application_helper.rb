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
    app_name = Rails.configuration.settings['app_full_name']
    if content_for(:title).present?
      "#{app_name} - #{content_for(:title)}"
    else
      "#{app_name}"
    end
  end

  def profile_name(profile, long=false)
    display_name = long ? profile.name : profile.short_name

    link_to display_name, url_for(profile), title: profile.name_with_type
  end
end
