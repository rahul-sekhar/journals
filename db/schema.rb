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

ActiveRecord::Schema.define(:version => 20130106092151) do

  create_table "academics", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "basic_skills", :force => true do |t|
    t.integer  "subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "basic_skills", ["subject_id"], :name => "index_basic_skills_on_subject_id", :unique => true

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "edited_at"
  end

  add_index "comments", ["post_id"], :name => "index_comments_on_post_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "guardians", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "relationship"
    t.string   "phone_numbers"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.string   "file_name"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["post_id"], :name => "index_images_on_post_id"

  create_table "milestones", :force => true do |t|
    t.integer  "strand_id"
    t.integer  "level"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "milestones", ["level"], :name => "index_milestones_on_level"
  add_index "milestones", ["strand_id"], :name => "index_milestones_on_strand_id"

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "user_id"
    t.boolean  "visible_to_students",  :default => false, :null => false
    t.boolean  "visible_to_guardians", :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_commented_at"
    t.datetime "edited_at"
  end

  add_index "posts", ["created_at"], :name => "index_posts_on_created_at"
  add_index "posts", ["last_commented_at"], :name => "index_posts_on_last_commented_at"
  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"
  add_index "posts", ["visible_to_guardians"], :name => "index_posts_on_guardians_restricted"
  add_index "posts", ["visible_to_students"], :name => "index_posts_on_students_restricted"

  create_table "posts_students", :id => false, :force => true do |t|
    t.integer "post_id"
    t.integer "student_id"
  end

  add_index "posts_students", ["post_id", "student_id"], :name => "index_posts_tagged_students_on_post_id_and_student_profile_id", :unique => true

  create_table "posts_tags", :id => false, :force => true do |t|
    t.integer "post_id"
    t.integer "tag_id"
  end

  add_index "posts_tags", ["post_id", "tag_id"], :name => "index_posts_subjects_on_post_id_and_subject_id", :unique => true

  create_table "posts_teachers", :id => false, :force => true do |t|
    t.integer "post_id"
    t.integer "teacher_id"
  end

  add_index "posts_teachers", ["post_id", "teacher_id"], :name => "index_posts_teachers_on_post_id_and_teacher_profile_id", :unique => true

  create_table "strands", :force => true do |t|
    t.integer  "academic_id"
    t.integer  "parent_strand_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "strands", ["academic_id"], :name => "index_strands_on_academic_id"
  add_index "strands", ["parent_strand_id"], :name => "index_strands_on_parent_strand_id"

  create_table "student_mentors", :id => false, :force => true do |t|
    t.integer "student_id"
    t.integer "teacher_id"
  end

  add_index "student_mentors", ["student_id", "teacher_id"], :name => "students_mentors_index", :unique => true

  create_table "student_observations", :force => true do |t|
    t.text     "content"
    t.integer  "post_id"
    t.integer  "student_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "student_observations", ["post_id", "student_id"], :name => "index_post_sections_on_post_id_and_student_profile_id"

  create_table "students", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "date_of_birth"
    t.string   "bloodgroup"
    t.string   "emergency_contact"
    t.text     "address"
    t.string   "application_form_file"
    t.string   "phone_numbers"
  end

  add_index "students", ["first_name", "last_name"], :name => "student_full_name_index"
  add_index "students", ["first_name"], :name => "index_student_profiles_on_first_name"
  add_index "students", ["last_name"], :name => "index_student_profiles_on_last_name"

  create_table "students_groups", :id => false, :force => true do |t|
    t.integer "student_id"
    t.integer "group_id"
  end

  add_index "students_groups", ["student_id", "group_id"], :name => "students_groups_index", :unique => true

  create_table "students_guardians", :id => false, :force => true do |t|
    t.integer "student_id"
    t.integer "guardian_id"
  end

  create_table "students_milestones", :force => true do |t|
    t.integer  "student_id"
    t.integer  "milestone_id"
    t.string   "status"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "students_milestones", ["student_id", "milestone_id"], :name => "students_milestones_index"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], :name => "index_subjects_on_name"

  create_table "teacher_academic_students", :id => false, :force => true do |t|
    t.integer  "teacher_academic_id"
    t.integer  "student_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teacher_academic_students", ["teacher_academic_id", "student_id"], :name => "academics_students_index"

  create_table "teacher_academics", :force => true do |t|
    t.integer  "academic_id"
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teacher_academics", ["academic_id", "teacher_id"], :name => "academics_teachers_index"

  create_table "teachers", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone_numbers"
    t.date     "date_of_birth"
    t.string   "bloodgroup"
    t.string   "emergency_contact"
    t.text     "address"
  end

  add_index "teachers", ["first_name", "last_name"], :name => "teacher_full_name_index"
  add_index "teachers", ["first_name"], :name => "index_teacher_profiles_on_first_name"
  add_index "teachers", ["last_name"], :name => "index_teacher_profiles_on_last_name"

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
  end

  add_index "units", ["student_id", "academic_id"], :name => "student_units_index"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.integer  "profile_id"
    t.string   "profile_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_username"
  add_index "users", ["profile_id", "profile_type"], :name => "users_profile_index"

end
