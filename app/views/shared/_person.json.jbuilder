json.(person, :id, :full_name, :name, :name_with_info)
json.(person, :mobile, :home_phone, :office_phone, :email, :additional_emails, :address, :notes)
json.type person.class.to_s
json.active person.active?
json.archived person.archived

json.editable can?(:update, person)

if person.is_a? Guardian
  json.parent_count person.number_of_students
end

if person.is_a? Student
  json.(person, :birthday, :blood_group)

  json.group_ids person.ordered_groups.map{ |group| group.id }
  json.mentor_ids person.ordered_mentors.map{ |mentor| mentor.id }

  json.guardians person.ordered_guardians do |guardian|
    json.partial! "shared/person", person: guardian
  end
end

if person.is_a? Teacher
  json.mentee_ids person.ordered_mentees.map{ |mentee| mentee.id }
end