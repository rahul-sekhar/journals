module ApplicationHelper
  def title(page_title)
    content_for(:title, page_title)
  end

  def page_title
    if content_for(:title).present?
      "Journals Demo - #{content_for(:title)}"
    else
      "Journals Demo"
    end
  end
end
