json.current_page @page
json.total_pages @total_pages

json.items @posts do |post|
  json.partial! "post", post: post
end