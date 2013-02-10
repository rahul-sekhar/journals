json.array!(@people) do |person|
  json.partial! "shared/person", person: person
end