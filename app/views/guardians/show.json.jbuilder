json.array!(@students) do |student|
  json.partial! "shared/person", person: student
end