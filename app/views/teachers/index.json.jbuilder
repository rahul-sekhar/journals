json.array!(@teachers) do |teacher|
  json.partial! "shared/person_short", person: teacher
end