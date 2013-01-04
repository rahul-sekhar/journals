class ChangeRestrictions < ActiveRecord::Migration
  def up
    change_table :posts do |t|
      t.rename :students_restricted, :visible_to_students
      t.rename :guardians_restricted, :visible_to_guardians
    end

    execute <<-SQL
      UPDATE posts SET visible_to_students = NOT visible_to_students;
      UPDATE posts SET visible_to_guardians = NOT visible_to_guardians;
    SQL
  end

  def down
    execute <<-SQL
      UPDATE posts SET visible_to_students = NOT visible_to_students;
      UPDATE posts SET visible_to_guardians = NOT visible_to_guardians;
    SQL

    change_table :posts do |t|
      t.rename :visible_to_students, :students_restricted
      t.rename :visible_to_guardians, :guardians_restricted
    end
  end
end
