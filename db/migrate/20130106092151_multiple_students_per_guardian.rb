class MultipleStudentsPerGuardian < ActiveRecord::Migration
  def up
    create_table :students_guardians, id: false do |t|
      t.integer :student_id
      t.integer :guardian_id
    end

    execute <<-SQL
      INSERT INTO "students_guardians" (guardian_id, student_id) (SELECT id, student_id FROM "guardians")
    SQL

    remove_column :guardians, :student_id
  end

  def down
    add_column :guardians, :student_id, :integer

    execute <<-SQL
      UPDATE guardians SET student_id = "students_guardians".student_id 
        FROM students_guardians WHERE "guardians".id = "students_guardians".guardian_id
    SQL

    drop_table :students_guardians
  end
end
