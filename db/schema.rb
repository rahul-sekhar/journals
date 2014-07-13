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

ActiveRecord::Schema.define(:version => 20140713171317) do

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.integer  "post_id",                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "author_id",                 :null => false
    t.string   "author_type", :limit => 10, :null => false
    t.index ["created_at"], :name => "index_comments_on_created_at"
    t.index ["post_id"], :name => "index_comments_on_post_id"
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
    t.index ["priority", "run_at"], :name => "delayed_jobs_priority"
  end

  create_table "groups", :force => true do |t|
    t.string   "name",       :limit => 50, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], :name => "index_groups_on_name", :unique => true
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
    t.index ["last_name", "first_name"], :name => "index_guardians_on_last_name_and_first_name"
  end

  create_table "images", :force => true do |t|
    t.string   "file_name"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["post_id"], :name => "index_images_on_post_id"
  end

  create_table "milestones", :force => true do |t|
    t.integer  "strand_id",  :null => false
    t.integer  "level",      :null => false
    t.text     "content",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",   :null => false
    t.index ["level"], :name => "index_milestones_on_level"
    t.index ["position"], :name => "index_milestones_on_position"
    t.index ["strand_id"], :name => "index_milestones_on_strand_id"
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
    t.index ["first_name", "last_name"], :name => "student_full_name_index"
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
    t.index ["first_name", "last_name"], :name => "teacher_full_name_index"
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
    t.index ["author_type", "author_id"], :name => "index_posts_on_author_type_and_author_id"
    t.index ["created_at"], :name => "index_posts_on_created_at"
    t.index ["title"], :name => "index_posts_on_title"
    t.index ["visible_to_guardians"], :name => "index_posts_on_guardians_restricted"
    t.index ["visible_to_students"], :name => "index_posts_on_students_restricted"
  end

  create_table "posts_students", :id => false, :force => true do |t|
    t.integer "post_id",    :null => false
    t.integer "student_id", :null => false
    t.index ["post_id", "student_id"], :name => "index_posts_tagged_students_on_post_id_and_student_profile_id", :unique => true
  end

  create_table "posts_tags", :id => false, :force => true do |t|
    t.integer "post_id", :null => false
    t.integer "tag_id",  :null => false
    t.index ["post_id", "tag_id"], :name => "index_posts_subjects_on_post_id_and_subject_id", :unique => true
  end

  create_table "posts_teachers", :id => false, :force => true do |t|
    t.integer "post_id",    :null => false
    t.integer "teacher_id", :null => false
    t.index ["post_id", "teacher_id"], :name => "index_posts_teachers_on_post_id_and_teacher_profile_id", :unique => true
  end

  create_view "profile_names", "(SELECT students.first_name, substr((students.last_name)::text, 1, 1) AS initial, 'Student'::text AS profile_type, students.id AS profile_id FROM students UNION ALL SELECT teachers.first_name, substr((teachers.last_name)::text, 1, 1) AS initial, 'Teacher'::text AS profile_type, teachers.id AS profile_id FROM teachers) UNION ALL SELECT guardians.first_name, substr((guardians.last_name)::text, 1, 1) AS initial, 'Guardian'::text AS profile_type, guardians.id AS profile_id FROM guardians", :force => true
  create_table "strands", :force => true do |t|
    t.integer  "subject_id",                     :null => false
    t.integer  "parent_strand_id"
    t.string   "name",             :limit => 80, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",                       :null => false
    t.index ["parent_strand_id"], :name => "index_strands_on_parent_strand_id"
    t.index ["position"], :name => "index_strands_on_position"
    t.index ["subject_id"], :name => "index_strands_on_academic_id"
    t.index ["subject_id"], :name => "index_strands_on_subject_id"
  end

  create_table "student_mentors", :id => false, :force => true do |t|
    t.integer "student_id", :null => false
    t.integer "teacher_id", :null => false
    t.index ["student_id", "teacher_id"], :name => "students_mentors_index", :unique => true
  end

  create_table "student_observations", :force => true do |t|
    t.text     "content",    :null => false
    t.integer  "post_id",    :null => false
    t.integer  "student_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["post_id", "student_id"], :name => "index_post_sections_on_post_id_and_student_profile_id"
  end

  create_table "students_groups", :id => false, :force => true do |t|
    t.integer "student_id", :null => false
    t.integer "group_id",   :null => false
    t.index ["student_id", "group_id"], :name => "students_groups_index", :unique => true
  end

  create_table "students_guardians", :id => false, :force => true do |t|
    t.integer "student_id",  :null => false
    t.integer "guardian_id", :null => false
    t.index ["guardian_id"], :name => "index_students_guardians_on_guardian_id"
    t.index ["student_id", "guardian_id"], :name => "index_students_guardians_on_student_id_and_guardian_id", :unique => true
  end

  create_table "students_milestones", :force => true do |t|
    t.integer  "student_id",                  :null => false
    t.integer  "milestone_id",                :null => false
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",       :default => 0, :null => false
    t.datetime "date"
    t.index ["date"], :name => "index_students_milestones_on_date"
    t.index ["student_id", "milestone_id"], :name => "students_milestones_index", :unique => true
  end

  create_table "subject_teacher_students", :id => false, :force => true do |t|
    t.integer  "subject_teacher_id", :null => false
    t.integer  "student_id",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["subject_teacher_id", "student_id"], :name => "academics_students_index"
  end

  create_table "subject_teachers", :force => true do |t|
    t.integer  "subject_id", :null => false
    t.integer  "teacher_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["subject_id", "teacher_id"], :name => "academics_teachers_index"
    t.index ["subject_id", "teacher_id"], :name => "index_subject_teachers_on_subject_id_and_teacher_id", :unique => true
  end

  create_table "subjects", :force => true do |t|
    t.string   "name",          :limit => 50,                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "column_name",                 :default => "Level", :null => false
    t.boolean  "level_numbers",               :default => true,    :null => false
  end

  create_table "units", :force => true do |t|
    t.integer  "student_id",               :null => false
    t.integer  "subject_id",               :null => false
    t.string   "name",       :limit => 80, :null => false
    t.date     "started"
    t.date     "due"
    t.date     "completed"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["student_id", "subject_id"], :name => "student_units_index"
  end

  create_view "summarized_academics", "SELECT sts.student_id, st.subject_id, st.teacher_id, u.id AS unit_id, max(sm.updated_at) AS framework_edited FROM ((((((subject_teachers st JOIN subject_teacher_students sts ON ((st.id = sts.subject_teacher_id))) LEFT JOIN units u ON (((u.student_id = sts.student_id) AND (u.subject_id = st.subject_id)))) LEFT JOIN units u2 ON ((((u2.student_id = sts.student_id) AND (u2.subject_id = st.subject_id)) AND (u.created_at < u2.created_at)))) LEFT JOIN strands str ON ((str.subject_id = st.subject_id))) LEFT JOIN milestones m ON ((m.strand_id = str.id))) LEFT JOIN students_milestones sm ON (((sm.student_id = sts.student_id) AND (sm.milestone_id = m.id)))) WHERE (u2.created_at IS NULL) GROUP BY sts.student_id, st.subject_id, st.teacher_id, u.id", :force => true
  create_table "tags", :force => true do |t|
    t.string   "name",       :limit => 50, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], :name => "index_tags_on_name", :unique => true
  end

  create_table "users", :force => true do |t|
    t.string   "email",         :limit => 60, :null => false
    t.string   "password_hash", :limit => 60
    t.string   "password_salt", :limit => 60, :null => false
    t.integer  "profile_id",                  :null => false
    t.string   "profile_type",  :limit => 10, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], :name => "index_users_on_email", :unique => true
    t.index ["profile_type", "profile_id"], :name => "index_users_on_profile_type_and_profile_id", :unique => true
  end

end
