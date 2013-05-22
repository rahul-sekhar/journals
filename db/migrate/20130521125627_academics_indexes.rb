class AcademicsIndexes < ActiveRecord::Migration
  def up
    add_index :milestones, :position
    add_index :strands, :subject_id
    add_index :strands, :position

    add_index :subject_teachers, [:subject_id, :teacher_id], unique: true
  end

  def down
    remove_index :milestones, :position
    remove_index :strands, :subject_id
    remove_index :strands, :position

    remove_index :subject_teachers, [:subject_id, :teacher_id]
  end
end
