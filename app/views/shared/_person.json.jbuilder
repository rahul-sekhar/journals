json.(person, :id, :full_name, :mobile, :home_phone, :office_phone, :email, :additional_emails, :address, :notes)
json.type person.class.to_s
json.active person.active?
json.archived person.archived

if person.is_a? Guardian
  json.number_of_students person.students.length
end

if person.is_a? Student
  json.(person, :formatted_birthday, :blood_group, :group_ids)

  json.guardians person.guardians do |guardian|
    json.partial! "shared/person", person: guardian
  end
end