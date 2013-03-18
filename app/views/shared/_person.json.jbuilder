json.(person, :id, :name, :short_name, :name_with_info)
json.(person, :mobile, :home_phone, :office_phone, :email, :additional_emails, :address, :notes)
json.type person.class.to_s
json.active person.active?
json.archived person.archived

json.editable can?(:update, person)

if person.is_a? Guardian
  json.parent_count person.number_of_students
end

if person.is_a? Student
  json.(person, :birthday, :blood_group, :group_ids, :mentor_ids)

  json.guardians person.guardians do |guardian|
    json.partial! "shared/person", person: guardian
  end
end

if person.is_a? Teacher
  json.(person, :mentee_ids)
end