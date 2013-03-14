json.array!(@teachers) do |teacher|
  json.type 'Teacher'
  json.(teacher, :id, :full_name)
end