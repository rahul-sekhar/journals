json.partial! "shared/person", person: @guardian

json.students @guardian.students do |student|
  json.partial! "shared/person", person: student
end