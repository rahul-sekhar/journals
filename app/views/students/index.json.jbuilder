json.array!(@students) do |student|
  json.partial! "shared/person_short", person: student
end