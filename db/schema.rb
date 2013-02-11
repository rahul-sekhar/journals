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

ActiveRecord::Schema.define(:version => 0) do

  create_table "academics", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_profiles", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_name"
    t.string   "email"
  end

  create_table "basic_skills", :force => true do |t|
    t.integer  "subject_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.index ["post_id"], :name => "index_comments_on_post_id", :order => {"post_id" => :asc}
  end

  create_table "edits", :force => true do |t|
    t.integer  "user_id"
    t.integer  "edited_content_id"
    t.string   "edited_content_type"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "guardians", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_numbers"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "relationship"
    t.integer  "student_profile_id"
    t.string   "display_name"
    t.string   "email"
    t.index ["display_name"], :name => "index_guardians_on_display_name", :order => {"display_name" => :asc}
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

  create_table "post_sections", :force => true do |t|
    t.text     "content"
    t.integer  "post_id"
    t.integer  "student_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["post_id", "student_profile_id"], :name => "index_post_sections_on_post_id_and_student_profile_id", :order => {"post_id" => :asc, "student_profile_id" => :asc}
  end

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.boolean  "students_restricted",        :default => false, :null => false
    t.boolean  "guardians_restricted",       :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_commented_at"
    t.integer  "user_id"
    t.boolean  "resource_people_restricted", :default => false, :null => false
    t.string   "type_name"
    t.index ["created_at"], :name => "index_posts_on_created_at", :order => {"created_at" => :asc}
    t.index ["guardians_restricted"], :name => "index_posts_on_guardians_restricted", :order => {"guardians_restricted" => :asc}
    t.index ["last_commented_at"], :name => "index_posts_on_last_commented_at", :order => {"last_commented_at" => :asc}
    t.index ["resource_people_restricted"], :name => "index_posts_on_resource_people_restricted", :order => {"resource_people_restricted" => :asc}
    t.index ["students_restricted"], :name => "index_posts_on_students_restricted", :order => {"students_restricted" => :asc}
  end

  create_table "posts_followups", :id => false, :force => true do |t|
    t.integer "post_id"
    t.integer "teacher_profile_id"
    t.index ["post_id", "teacher_profile_id"], :name => "index_posts_followups_on_post_id_and_teacher_profile_id", :unique => true, :order => {"post_id" => :asc, "teacher_profile_id" => :asc}
  end

  create_table "posts_subjects", :id => false, :force => true do |t|
    t.integer "post_id"
    t.integer "subject_id"
    t.index ["post_id", "subject_id"], :name => "index_posts_subjects_on_post_id_and_subject_id", :unique => true, :order => {"post_id" => :asc, "subject_id" => :asc}
  end

  create_table "posts_tagged_students", :id => false, :force => true do |t|
    t.integer "post_id"
    t.integer "student_profile_id"
    t.index ["post_id", "student_profile_id"], :name => "index_posts_tagged_students_on_post_id_and_student_profile_id", :unique => true, :order => {"post_id" => :asc, "student_profile_id" => :asc}
  end

  create_table "posts_teachers", :id => false, :force => true do |t|
    t.integer "post_id"
    t.integer "teacher_profile_id"
    t.index ["post_id", "teacher_profile_id"], :name => "index_posts_teachers_on_post_id_and_teacher_profile_id", :unique => true, :order => {"post_id" => :asc, "teacher_profile_id" => :asc}
  end

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
    t.integer "student_profile_id"
    t.integer "teacher_profile_id"
    t.index ["student_profile_id", "teacher_profile_id"], :name => "students_mentors_index", :unique => true, :order => {"student_profile_id" => :asc, "teacher_profile_id" => :asc}
  end

  create_table "student_profiles", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "date_of_birth"
    t.string   "bloodgroup"
    t.text     "address"
    t.string   "application_form_file"
    t.string   "phone_numbers"
    t.string   "emergency_contact"
    t.string   "display_name"
    t.string   "email"
    t.index ["display_name"], :name => "index_student_profiles_on_display_name", :order => {"display_name" => :asc}
    t.index ["first_name"], :name => "index_student_profiles_on_first_name", :order => {"first_name" => :asc}
    t.index ["last_name"], :name => "index_student_profiles_on_last_name", :order => {"last_name" => :asc}
    t.index ["first_name", "last_name"], :name => "student_full_name_index", :order => {"first_name" => :asc, "last_name" => :asc}
  end

  create_table "student_profiles_groups", :id => false, :force => true do |t|
    t.integer "student_profile_id"
    t.integer "group_id"
    t.index ["student_profile_id", "group_id"], :name => "students_groups_index", :unique => true, :order => {"student_profile_id" => :asc, "group_id" => :asc}
  end

  create_table "students_interests", :id => false, :force => true do |t|
    t.integer "student_profile_id"
    t.integer "subject_id"
    t.index ["student_profile_id", "subject_id"], :name => "index_students_interests_on_student_profile_id_and_subject_id", :unique => true, :order => {"student_profile_id" => :asc, "subject_id" => :asc}
  end

  create_table "students_milestones", :force => true do |t|
    t.integer  "student_profile_id"
    t.integer  "milestone_id"
    t.string   "status"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["student_profile_id", "milestone_id"], :name => "students_milestones_index", :order => {"student_profile_id" => :asc, "milestone_id" => :asc}
  end

  create_table "subjects", :force => true do |t|
    t.string   "name",       :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], :name => "index_subjects_on_name", :order => {"name" => :asc}
  end

  create_table "teacher_academic_students", :id => false, :force => true do |t|
    t.integer  "teacher_academic_id"
    t.integer  "student_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["teacher_academic_id", "student_profile_id"], :name => "academics_students_index", :order => {"teacher_academic_id" => :asc, "student_profile_id" => :asc}
  end

  create_table "teacher_academics", :force => true do |t|
    t.integer  "academic_id"
    t.integer  "teacher_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["academic_id", "teacher_profile_id"], :name => "academics_teachers_index", :order => {"academic_id" => :asc, "teacher_profile_id" => :asc}
  end

  create_table "teacher_profiles", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone_numbers"
    t.text     "address"
    t.string   "emergency_contact"
    t.string   "bloodgroup"
    t.string   "date_of_birth"
    t.string   "display_name"
    t.string   "email"
    t.index ["display_name"], :name => "index_teacher_profiles_on_display_name", :order => {"display_name" => :asc}
    t.index ["first_name"], :name => "index_teacher_profiles_on_first_name", :order => {"first_name" => :asc}
    t.index ["last_name"], :name => "index_teacher_profiles_on_last_name", :order => {"last_name" => :asc}
    t.index ["first_name", "last_name"], :name => "teacher_full_name_index", :order => {"first_name" => :asc, "last_name" => :asc}
  end

  create_table "units", :force => true do |t|
    t.integer  "student_profile_id"
    t.integer  "academic_id"
    t.string   "name"
    t.date     "started"
    t.date     "due"
    t.date     "completed"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["student_profile_id", "academic_id"], :name => "student_units_index", :order => {"student_profile_id" => :asc, "academic_id" => :asc}
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password_hash"
    t.string   "password_salt"
    t.integer  "profile_id"
    t.string   "profile_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.index ["username"], :name => "index_users_on_username", :order => {"username" => :asc}
    t.index ["profile_id", "profile_type"], :name => "users_profile_index", :order => {"profile_id" => :asc, "profile_type" => :asc}
  end

end
