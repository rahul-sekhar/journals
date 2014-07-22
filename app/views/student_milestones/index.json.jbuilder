json.array!(@student_milestones) do |student_milestone|
  json.(student_milestone, :id, :status, :status_text, :comments, :date)
  json.(student_milestone.milestone, :level, :content, :headings)
end