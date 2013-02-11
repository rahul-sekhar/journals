json.(person, :id, :full_name, :mobile, :home_phone, :office_phone, :email, :additional_emails, :address, :notes)
json.type person.class.to_s.downcase.pluralize

if person.is_a? Student
  json.(person, :formatted_birthday, :blood_group)

  json.guardians person.guardians do |guardian|
    json.partial! "shared/person", person: guardian
  end
end