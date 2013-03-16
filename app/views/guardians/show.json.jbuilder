json.partial! "shared/person", person: @guardian

json.students @students do |student|
  json.partial! "shared/person", person: student
end