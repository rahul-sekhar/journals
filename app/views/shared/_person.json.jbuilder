json.(person, :id, :full_name, :mobile, :home_phone, :office_phone, :email, :additional_emails, :address, :notes)
json.type person.class.to_s
json.active person.active?
json.archived person.archived

json.editable can?(:update, person)

if person.is_a? Guardian
  json.parent_count person.students.length
end

if person.is_a? Student
  json.(person, :formatted_birthday, :blood_group, :group_ids, :mentor_ids)

  json.guardians person.guardians.alphabetical do |guardian|
    json.partial! "shared/person", person: guardian
  end
end

if person.is_a? Teacher
  json.(person, :mentee_ids)
end