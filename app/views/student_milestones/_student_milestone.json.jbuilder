json.id student_milestone.destroyed? ? nil : student_milestone.id
json.(student_milestone, :milestone_id, :status, :comments)