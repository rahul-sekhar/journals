class CreateAcademicsView < ActiveRecord::Migration
  def up
    create_view :summarized_academics, <<-SQL
      SELECT sts.student_id, st.subject_id, st.teacher_id, u.id unit_id, MAX(sm.updated_at) framework_edited

      FROM subject_teachers st

      INNER JOIN subject_teacher_students AS sts ON st.id=sts.subject_teacher_id

      LEFT JOIN units u ON (
        u.student_id = sts.student_id AND
        u.subject_id = st.subject_id
      )

      LEFT JOIN units u2 ON (
        u2.student_id = sts.student_id AND
        u2.subject_id = st.subject_id AND
        u.created_at < u2.created_at
      )

      LEFT JOIN strands str ON (str.subject_id = st.subject_id)

      LEFT JOIN milestones m ON (m.strand_id = str.id)

      LEFT JOIN students_milestones sm ON
        (sm.student_id = sts.student_id AND sm.milestone_id = m.id)

      WHERE u2.created_at IS NULL

      GROUP BY sts.student_id, st.subject_id, st.teacher_id, unit_id
    SQL
  end

  def down
    drop_view :summarized_academics
  end
end

