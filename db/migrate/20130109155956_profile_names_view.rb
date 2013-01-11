class ProfileNamesView < ActiveRecord::Migration
  def up
    create_view :profile_names, <<-SQL
      SELECT first_name, SUBSTR(last_name, 1, 1) AS initial, 
        'Student' AS profile_type, id AS profile_id FROM students
        UNION ALL
      
      SELECT first_name, SUBSTR(last_name, 1, 1) AS initial, 
        'Teacher' AS profile_type, id AS profile_id FROM teachers
        UNION ALL

      SELECT first_name, SUBSTR(last_name, 1, 1) AS initial, 
        'Guardian' AS profile_type, id AS profile_id FROM guardians
    SQL
  end

  def down
    drop_view :profile_names
  end
end
