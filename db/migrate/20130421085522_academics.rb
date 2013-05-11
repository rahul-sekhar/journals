class Academics < ActiveRecord::Migration
  def up
    rename_table :academics, :subjects
    change_column :subjects, :name, :string, null: false, limit: 50

    change_column :milestones, :strand_id, :integer, null: false
    change_column :milestones, :level, :integer, null: false

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

    change_column :strands, :academic_id, :integer, null: false
    rename_column :strands, :academic_id, :subject_id
    change_column :strands, :parent_strand_id, :integer, null: false
    change_column :strands, :name, :string, null: false, limit: 80

    rename_table :teacher_academic_students, :teacher_subject_students
    add_column :teacher_subject_students, :teacher_id, :integer, null: false
    add_column :teacher_subject_students, :subject_id, :integer, null: false
    execute <<-SQL
      UPDATE teacher_subject_students SET teacher_id="teacher_academics".teacher_id
        FROM teacher_academics WHERE teacher_academic_id="teacher_academics".id;

      UPDATE teacher_subject_students SET subject_id="teacher_academics".academic_id
        FROM teacher_academics WHERE teacher_academic_id="teacher_academics".id;
    SQL
    remove_column :teacher_subject_students, :teacher_academic_id

    drop_table :teacher_academics

    change_column :units, :student_id, :integer, null: false
    change_column :units, :academic_id, :integer, null: false
    rename_column :units, :academic_id, :subject_id
    change_column :units, :name, :string, null: false, limit: 80
  end

  def down
    puts "*** Not reversible ***"
  end
end
