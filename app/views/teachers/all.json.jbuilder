json.array!(@teachers) do |teacher|
  json.id teacher.id
  json.name teacher.full_name
end