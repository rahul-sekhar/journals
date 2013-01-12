class ChangeView < ActiveRecord::Migration
  def up
    drop_view :people
    create_view :people, <<-SQL
      SELECT ARRAY_TO_STRING(ARRAY[first_name, last_name], ' ') AS full_name, archived, 
        'Student' AS profile_type, id AS profile_id FROM students
        UNION ALL
      
      SELECT ARRAY_TO_STRING(ARRAY[first_name, last_name], ' ') AS full_name, archived,
        'Teacher' AS profile_type, id AS profile_id FROM teachers
    SQL
  end

  def down
    drop_view :people
    create_view :people, <<-SQL
      SELECT (first_name || ' ' || last_name) AS full_name, archived, 
        'Student' AS profile_type, id AS profile_id FROM students
        UNION ALL
      
      SELECT (first_name || ' ' || last_name) AS full_name, archived,
        'Teacher' AS profile_type, id AS profile_id FROM teachers
    SQL
  end
end
