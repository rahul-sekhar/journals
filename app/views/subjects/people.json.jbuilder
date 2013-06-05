json.(@subject, :id, :name)

json.subject_teachers @subject.subject_teachers do |subject_teacher|
  json.partial! "subject_teachers/subject_teacher", subject_teacher: subject_teacher
end