json.array!(@subjects) do |subject|
  json.(subject, :name, :id)
end