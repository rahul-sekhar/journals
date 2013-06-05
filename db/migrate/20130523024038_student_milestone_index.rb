class StudentMilestoneIndex < ActiveRecord::Migration
  def up
    remove_index :students_milestones, name: :students_milestones_index
    add_index :students_milestones, [:student_id, :milestone_id], unique: true, name: :students_milestones_index
  end

  def down
    remove_index :students_milestones, name: :students_milestones_index
    add_index :students_milestones, [:student_id, :milestone_id], name: :students_milestones_index
  end
end
