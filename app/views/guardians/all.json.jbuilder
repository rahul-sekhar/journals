json.array!(@guardians) do |guardian|
  json.partial! "shared/person_short", person: guardian
end