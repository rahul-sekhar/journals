class RenameProfiles < ActiveRecord::Migration
  def up
    rename_table :admin_profiles, :admins
    rename_column :guardians, :student_profile_id, :student_id
    rename_column :post_sections, :student_profile_id, :student_id
    rename_column :posts_tagged_students, :student_profile_id, :student_id
    rename_table :posts_tagged_students, :posts_students
    rename_column :posts_teachers, :teacher_profile_id, :teacher_id
    rename_column :student_mentors, :student_profile_id, :student_id
    rename_column :student_mentors, :teacher_profile_id, :teacher_id
    rename_table :student_profiles, :students
    rename_column :student_profiles_groups, :student_profile_id, :student_id
    rename_table :student_profiles_groups, :students_groups
    rename_column :students_milestones, :student_profile_id, :student_id
    rename_column :teacher_academic_students, :student_profile_id, :student_id
    rename_column :teacher_academics, :teacher_profile_id, :teacher_id
    rename_table :teacher_profiles, :teachers
    rename_column :units, :student_profile_id, :student_id
  end

  def down
    rename_table :admins, :admin_profiles
    rename_column :guardians, :student_id, :student_profile_id
    rename_column :post_sections, :student_id, :student_profile_id
    rename_column :posts_students, :student_id, :student_profile_id
    rename_table :posts_students, :posts_tagged_students
    rename_column :posts_teachers, :teacher_id, :teacher_profile_id
    rename_column :student_mentors, :student_id, :student_profile_id
    rename_column :student_mentors, :teacher_id, :teacher_profile_id
    rename_table :students, :student_profiles
    rename_column :students_groups, :student_id, :student_profile_id
    rename_table :students_groups, :student_profiles_groups
    rename_column :students_milestones, :student_id, :student_profile_id
    rename_column :teacher_academic_students, :student_id, :student_profile_id
    rename_column :teacher_academics, :teacher_id, :teacher_profile_id
    rename_table :teachers, :teacher_profiles
    rename_column :units, :student_id, :student_profile_id
  end
end
