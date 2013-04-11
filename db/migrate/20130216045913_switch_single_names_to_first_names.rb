class Student < ActiveRecord::Base
end

class Teacher < ActiveRecord::Base
end

class Guardian < ActiveRecord::Base
end

class SwitchSingleNamesToFirstNames < ActiveRecord::Migration
  def up
    drop_view :profile_names
    drop_view :people

    change_column :students, :last_name, :string, null: true, limit: 80
    change_column :teachers, :last_name, :string, null: true, limit: 80
    change_column :guardians, :last_name, :string, null: true, limit: 80

    Student.all.each do |profile|
      if profile.first_name.blank?
        profile.first_name = profile.last_name
        profile.last_name = nil
        puts "Saving: " + profile.first_name
        profile.save!
      end
    end

    Teacher.all.each do |profile|
      if profile.first_name.blank?
        profile.first_name = profile.last_name
        profile.last_name = nil
        puts "Saving: " + profile.first_name
        profile.save!
      end
    end

    Guardian.all.each do |profile|
      if profile.first_name.blank?
        profile.first_name = profile.last_name
        profile.last_name = nil
        puts "Saving: " + profile.first_name
        profile.save!
      end
    end

    change_column :students, :first_name, :string, null: false, limit: 80
    change_column :teachers, :first_name, :string, null: false, limit: 80
    change_column :guardians, :first_name, :string, null: false, limit: 80

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

    create_view :people, <<-SQL
      SELECT ARRAY_TO_STRING(ARRAY[first_name, last_name], ' ') AS full_name, archived, 
        'Student' AS profile_type, id AS profile_id FROM students
        UNION ALL
      
      SELECT ARRAY_TO_STRING(ARRAY[first_name, last_name], ' ') AS full_name, archived,
        'Teacher' AS profile_type, id AS profile_id FROM teachers
    SQL
  end

  def down
    drop_view :profile_names
    drop_view :people

    change_column :students, :first_name, :string, null: true, limit: 80
    change_column :teachers, :first_name, :string, null: true, limit: 80
    change_column :guardians, :first_name, :string, null: true, limit: 80

    Student.all.each do |profile|
      if profile.last_name.blank?
        profile.last_name = profile.first_name
        profile.first_name = nil
        puts "Saving: " + profile.last_name
        profile.save!
      end
    end

    Teacher.all.each do |profile|
      if profile.last_name.blank?
        profile.last_name = profile.first_name
        profile.first_name = nil
        puts "Saving: " + profile.last_name
        profile.save!
      end
    end

    Guardian.all.each do |profile|
      if profile.last_name.blank?
        profile.last_name = profile.first_name
        profile.first_name = nil
        puts "Saving: " + profile.last_name
        profile.save!
      end
    end

    change_column :students, :last_name, :string, null: false, limit: 80
    change_column :teachers, :last_name, :string, null: false, limit: 80
    change_column :guardians, :last_name, :string, null: false, limit: 80

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

    create_view :people, <<-SQL
      SELECT ARRAY_TO_STRING(ARRAY[first_name, last_name], ' ') AS full_name, archived, 
        'Student' AS profile_type, id AS profile_id FROM students
        UNION ALL
      
      SELECT ARRAY_TO_STRING(ARRAY[first_name, last_name], ' ') AS full_name, archived,
        'Teacher' AS profile_type, id AS profile_id FROM teachers
    SQL
  end
end
