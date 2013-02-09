json.array!(@people) do |person|
  json.(person, :id, :full_name, :mobile, :home_phone, :office_phone, :email, :additional_emails)
  json.type person.class.to_s.downcase.pluralize
end