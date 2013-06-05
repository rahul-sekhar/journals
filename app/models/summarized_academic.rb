class SummarizedAcademic < ActiveRecord::Base
  belongs_to :unit
  belongs_to :subject
  belongs_to :student
  belongs_to :teacher

  delegate :name, to: :unit, prefix: true, allow_nil: true
  delegate :due_date, to: :unit, allow_nil: true

  def self.for_teacher(teacher)
    where(teacher_id: teacher.id)
  end

  def self.for_students(student_ids)
    where(student_id: student_ids).
      select("student_id, subject_id, framework_edited, unit_id").
      group(:student_id, :subject_id, :framework_edited, :unit_id)
  end

  def framework_edited_date
    framework_edited && framework_edited.strftime( '%d-%m-%Y' )
  end

  def framework_edited_text
    framework_edited_date && "edited #{framework_edited_date}"
  end
end