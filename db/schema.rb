# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130403110758) do

  create_table "academics", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.integer  "post_id",                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "author_id",                 :null => false
    t.string   "author_type", :limit => 10, :null => false
    t.index ["created_at"], :name => "index_comments_on_created_at", :order => {"created_at" => :asc}
    t.index ["post_id"], :name => "index_comments_on_post_id", :order => {"post_id" => :asc}
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.index ["priority", "run_at"], :name => "delayed_jobs_priority", :order => {"priority" => :asc, "run_at" => :asc}
  end

  create_table "groups", :force => true do |t|
    t.string   "name",       :limit => 50, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], :name => "index_groups_on_name", :unique => true, :order => {"name" => :asc}
  end

  create_table "guardians", :force => true do |t|
    t.string   "first_name",        :limit => 80,  :null => false
    t.string   "last_name",         :limit => 80
    t.string   "mobile",            :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "home_phone",        :limit => 40
    t.string   "office_phone",      :limit => 40
    t.text     "address"
    t.string   "additional_emails", :limit => 100
    t.text     "notes"
    t.string   "short_name",        :limit => 161
    t.index ["last_name", "first_name"], :name => "index_guardians_on_last_name_and_first_name", :order => {"last_name" => :asc, "first_name" => :asc}
  end

  create_table "images", :force => true do |t|
    t.string   "file_name"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["post_id"], :name => "index_images_on_post_id", :order => {"post_id" => :asc}
  end

  create_table "milestones", :force => true do |t|
    t.integer  "strand_id"
    t.integer  "level"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["level"], :name => "index_milestones_on_level", :order => {"level" => :asc}
    t.index ["strand_id"], :name => "index_milestones_on_strand_id", :order => {"strand_id" => :asc}
  end

  create_table "null_table", :force => true do |t|
    t.integer "foreign_id"
  end

  create_table "students", :force => true do |t|
    t.string   "first_name",            :limit => 80,                     :null => false
    t.string   "last_name",             :limit => 80
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "birthday_raw"
    t.string   "blood_group",           :limit => 15
    t.text     "address"
    t.string   "application_form_file"
    t.string   "home_phone",            :limit => 40
    t.string   "mobile",                :limit => 40
    t.string   "office_phone",          :limit => 40
    t.boolean  "archived",                             :default => false, :null => false
    t.string   "additional_emails",     :limit => 100
    t.text     "notes"
    t.string   "short_name",            :limit => 161
    t.index ["first_name", "last_name"], :name => "student_full_name_index", :order => {"first_name" => :asc, "last_name" => :asc}
  end

  create_table "teachers", :force => true do |t|
    t.string   "first_name",        :limit => 80,                     :null => false
    t.string   "last_name",         :limit => 80
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mobile",            :limit => 40
    t.text     "address"
    t.string   "home_phone",        :limit => 40
    t.string   "office_phone",      :limit => 40
    t.boolean  "archived",                         :default => false, :null => false
    t.string   "additional_emails", :limit => 100
    t.text     "notes"
    t.string   "short_name",        :limit => 161
    t.index ["first_name", "last_name"], :name => "teacher_full_name_index", :order => {"first_name" => :asc, "last_name" => :asc}
  end

  create_view "people", "SELECT array_to_string(ARRAY[students.first_name, students.last_name], ' '::text) AS full_name, students.archived, 'Student'::text AS profile_type, students.id AS profile_id FROM students UNION ALL SELECT array_to_string(ARRAY[teachers.first_name, teachers.last_name], ' '::text) AS full_name, teachers.archived, 'Teacher'::text AS profile_type, teachers.id AS profile_id FROM teachers", :force => true
  create_table "posts", :force => true do |t|
    t.string   "title",                                                 :null => false
    t.text     "content"
    t.boolean  "visible_to_students",                :default => false, :null => false
    t.boolean  "visible_to_guardians",               :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "author_id",                                             :null => false
    t.string   "author_type",          :limit => 10,                    :null => false
    t.index ["author_type", "author_id"], :name => "index_posts_on_author_type_and_author_id", :order => {"author_type" => :asc, "author_id" => :asc}
    t.index ["created_at"], :name => "index_posts_on_created_at", :order => {"created_at" => :asc}
    t.index ["visible_to_guardians"], :name => "index_posts_on_guardians_restricted", :order => {"visible_to_guardians" => :asc}
    t.index ["visible_to_students"], :name => "index_posts_on_students_restricted", :order => {"visible_to_students" => :asc}
    t.index ["title"], :name => "index_posts_on_title", :order => {"title" => :asc}
  end

  create_table "posts_students", :id => false, :force => true do |t|
    t.integer "post_id",    :null => false
    t.integer "student_id", :null => false
    t.index ["post_id", "student_id"], :name => "index_posts_tagged_students_on_post_id_and_student_profile_id", :unique => true, :order => {"post_id" => :asc, "student_id" => :asc}
  end

  create_table "posts_tags", :id => false, :force => true do |t|
    t.integer "post_id", :null => false
    t.integer "tag_id",  :null => false
    t.index ["post_id", "tag_id"], :name => "index_posts_subjects_on_post_id_and_subject_id", :unique => true, :order => {"post_id" => :asc, "tag_id" => :asc}
  end

  create_table "posts_teachers", :id => false, :force => true do |t|
    t.integer "post_id",    :null => false
    t.integer "teacher_id", :null => false
    t.index ["post_id", "teacher_id"], :name => "index_posts_teachers_on_post_id_and_teacher_profile_id", :unique => true, :order => {"post_id" => :asc, "teacher_id" => :asc}
  end

  create_view "profile_names", "(SELECT students.first_name, substr((students.last_name)::text, 1, 1) AS initial, 'Student'::text AS profile_type, students.id AS profile_id FROM students UNION ALL SELECT teachers.first_name, substr((teachers.last_name)::text, 1, 1) AS initial, 'Teacher'::text AS profile_type, teachers.id AS profile_id FROM teachers) UNION ALL SELECT guardians.first_name, substr((guardians.last_name)::text, 1, 1) AS initial, 'Guardian'::text AS profile_type, guardians.id AS profile_id FROM guardians", :force => true
  create_table "strands", :force => true do |t|
    t.integer  "academic_id"
    t.integer  "parent_strand_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["academic_id"], :name => "index_strands_on_academic_id", :order => {"academic_id" => :asc}
    t.index ["parent_strand_id"], :name => "index_strands_on_parent_strand_id", :order => {"parent_strand_id" => :asc}
  end

  create_table "student_mentors", :id => false, :force => true do |t|
    t.integer "student_id", :null => false
    t.integer "teacher_id", :null => false
    t.index ["student_id", "teacher_id"], :name => "students_mentors_index", :unique => true, :order => {"student_id" => :asc, "teacher_id" => :asc}
  end

  create_table "student_observations", :force => true do |t|
    t.text     "content",    :null => false
    t.integer  "post_id",    :null => false
    t.integer  "student_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["post_id", "student_id"], :name => "index_post_sections_on_post_id_and_student_profile_id", :order => {"post_id" => :asc, "student_id" => :asc}
  end

  create_table "students_groups", :id => false, :force => true do |t|
    t.integer "student_id", :null => false
    t.integer "group_id",   :null => false
    t.index ["student_id", "group_id"], :name => "students_groups_index", :unique => true, :order => {"student_id" => :asc, "group_id" => :asc}
  end

  create_table "students_guardians", :id => false, :force => true do |t|
    t.integer "student_id",  :null => false
    t.integer "guardian_id", :null => false
    t.index ["guardian_id"], :name => "index_students_guardians_on_guardian_id", :order => {"guardian_id" => :asc}
    t.index ["student_id", "guardian_id"], :name => "index_students_guardians_on_student_id_and_guardian_id", :unique => true, :order => {"student_id" => :asc, "guardian_id" => :asc}
  end

  create_table "students_milestones", :force => true do |t|
    t.integer  "student_id"
    t.integer  "milestone_id"
    t.string   "status"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["student_id", "milestone_id"], :name => "students_milestones_index", :order => {"student_id" => :asc, "milestone_id" => :asc}
  end

  create_table "tags", :force => true do |t|
    t.string   "name",       :limit => 50, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], :name => "index_tags_on_name", :unique => true, :order => {"name" => :asc}
  end

  create_table "teacher_academic_students", :id => false, :force => true do |t|
    t.integer  "teacher_academic_id"
    t.integer  "student_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["teacher_academic_id", "student_id"], :name => "academics_students_index", :order => {"teacher_academic_id" => :asc, "student_id" => :asc}
  end

  create_table "teacher_academics", :force => true do |t|
    t.integer  "academic_id"
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["academic_id", "teacher_id"], :name => "academics_teachers_index", :order => {"academic_id" => :asc, "teacher_id" => :asc}
  end

  create_table "units", :force => true do |t|
    t.integer  "student_id"
    t.integer  "academic_id"
    t.string   "name"
    t.date     "started"
    t.date     "due"
    t.date     "completed"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["student_id", "academic_id"], :name => "student_units_index", :order => {"student_id" => :asc, "academic_id" => :asc}
  end

  create_table "users", :force => true do |t|
    t.string   "email",         :limit => 60, :null => false
    t.string   "password_hash", :limit => 60
    t.string   "password_salt", :limit => 60, :null => false
    t.integer  "profile_id",                  :null => false
    t.string   "profile_type",  :limit => 10, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], :name => "index_users_on_email", :unique => true, :order => {"email" => :asc}
    t.index ["profile_type", "profile_id"], :name => "index_users_on_profile_type_and_profile_id", :unique => true, :order => {"profile_type" => :asc, "profile_id" => :asc}
  end

end
