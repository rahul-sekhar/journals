json.(person, :id, :full_name, :mobile, :home_phone, :office_phone, :email, :additional_emails, :address, :notes)
json.(person, :formatted_birthday, :blood_group) if person.is_a? Student
json.type person.class.to_s.downcase.pluralize