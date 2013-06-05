json.array!(@summarized_academics) do |summary|
  json.(summary, :student_id, :subject_id)
  json.student summary.student.short_name
  json.subject summary.subject.name
  json.unit summary.unit_name
  json.due_date summary.due_date
  json.framework_edited summary.framework_edited_text
end