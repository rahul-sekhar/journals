json.current_page @page
json.total_pages @total_pages

json.items @people do |person|
  json.partial! "shared/person", person: person
end