json.(@subject, :id, :name)

json.subject_teachers @subject.subject_teachers do |subject_teacher|
  json.partial! "subject_teacher", subject_teacher: subject_teacher
end