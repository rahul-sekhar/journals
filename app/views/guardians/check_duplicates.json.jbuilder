json.array!(@duplicate_guardians) do |guardian|
  json.id guardian.id
  json.students guardian.students_as_sentence
end