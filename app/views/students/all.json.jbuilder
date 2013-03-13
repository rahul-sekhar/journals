json.array!(@students) do |student|
  json.id student.id
  json.name student.full_name
end