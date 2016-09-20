json.(@subject, :name, :column_name, :level_numbers, :id)

json.strands @subject.root_strands do |strand|
  json.partial! "strand", strand: strand
end

if @student
  json.student_milestones @student.student_milestones.from_subject(@subject) do |student_milestone|
    json.partial! "student_milestones/student_milestone", student_milestone: student_milestone
  end
end