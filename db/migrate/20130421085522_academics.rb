class Academics < ActiveRecord::Migration
  def up
    rename_table :academics, :subjects
    change_column :subjects, :name, :string, null: false, limit: 50

    change_column :milestones, :strand_id, :integer, null: false
    change_column :milestones, :level, :integer, null: false
    add_column :milestones, :position, :integer, null: false

    change_column :students_milestones, :student_id, :integer, null: false
    change_column :students_milestones, :milestone_id, :integer, null: false
    rename_column :students_milestones, :status, :status_text
    add_column :students_milestones, :status, :integer, null: false, default: 0
    execute <<-SQL
      UPDATE students_milestones SET status=1 WHERE status_text='learning';
      UPDATE students_milestones SET status=2 WHERE status_text='having_difficulty';
      UPDATE students_milestones SET status=3 WHERE status_text='learnt';
    SQL
    remove_column :students_milestones, :status_text

    rename_column :strands, :academic_id, :subject_id
    change_column :strands, :subject_id, :integer, null: false
    change_column :strands, :parent_strand_id, :integer, null: false
    change_column :strands, :name, :string, null: false, limit: 80
    add_column :strands, :position, :integer, null: false

    rename_table :teacher_academics, :subject_teachers
    rename_column :subject_teachers, :academic_id, :subject_id
    change_column :subject_teachers, :subject_id, :integer, null: false
    change_column :subject_teachers, :teacher_id, :integer, null: false

    rename_table :teacher_academic_students, :subject_teacher_students
    rename_column :subject_teacher_students, :teacher_academic_id, :subject_teacher_id
    change_column :subject_teacher_students, :subject_teacher_id, :integer, null: false
    change_column :subject_teacher_students, :student_id, :integer, null: false

    change_column :units, :student_id, :integer, null: false
    change_column :units, :academic_id, :integer, null: false
    rename_column :units, :academic_id, :subject_id
    change_column :units, :name, :string, null: false, limit: 80
  end

  def down
    puts "*** Data integrity will not be retained for academics ***"

    rename_table :subjects, :academics
    change_column :academics, :name, :string, null: true

    change_column :milestones, :strand_id, :integer, null: true
    change_column :milestones, :level, :integer, null: true
    remove_column :milestones, :position

    change_column :students_milestones, :student_id, :integer, null: true
    change_column :students_milestones, :milestone_id, :integer, null: true
    remove_column :students_milestones, :status
    add_column :students_milestones, :status, :string

    rename_column :strands, :subject_id, :academic_id
    change_column :strands, :academic_id, :integer, null: true
    change_column :strands, :parent_strand_id, :integer, null: true
    change_column :strands, :name, :string, null: true
    remove_column :strands, :position

    rename_table :subject_teachers, :teacher_academics
    rename_column :teacher_academics, :subject_id, :academic_id
    change_column :teacher_academics, :academic_id, :integer, null: true
    change_column :teacher_academics, :teacher_id, :integer, null: true

    rename_table :subject_teacher_students, :teacher_academic_students
    rename_column :teacher_academic_students, :subject_teacher_id, :teacher_academic_id
    change_column :teacher_academic_students, :teacher_academic_id, :integer, null: true
    change_column :teacher_academic_students, :student_id, :integer, null: true

    change_column :units, :student_id, :integer, null: true
    change_column :units, :subject_id, :integer, null: true
    rename_column :units, :subject_id, :academic_id
    change_column :units, :name, :string, null: true
  end
end
