module ApplicationHelper
  def title(page_title)
    content_for(:title, page_title)
    content_for(:heading, page_title)
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
end
