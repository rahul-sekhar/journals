json.array!(@students) do |student|
  json.type 'Student'
  json.(student, :id, :full_name)
end