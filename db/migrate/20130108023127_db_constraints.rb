class DbConstraints < ActiveRecord::Migration
  def up
    drop_table :basic_skills

    # Comments
    change_column :comments, :post_id, :integer, null: false
    change_column :comments, :author_id, :integer, null: false
    change_column :comments, :author_type, :string, null: false, limit: 10

    add_index :comments, :created_at

    # Groups
    change_column :groups, :name, :string, null: false, limit: 50
    
    add_index :groups, :name, unique: true

    # Guardians
    change_column :guardians, :first_name, :string, limit: 80
    change_column :guardians, :last_name, :string, null: false, limit: 80
    change_column :guardians, :mobile, :string, limit: 40
    change_column :guardians, :home_phone, :string, limit: 40
    change_column :guardians, :office_phone, :string, limit: 40

    add_index :guardians, [:last_name, :first_name]

    # Images
    change_column :images, :post_id, :integer, null: false

    # Posts
    change_column :posts, :title, :string, null: false, limit: 255
    remove_column :posts, :last_commented_at
    change_column :posts, :author_id, :integer, null: false
    change_column :posts, :author_type, :string, null: false, limit: 10

    add_index :posts, [:author_type, :author_id]
    add_index :posts, :title

    # Posts students
    change_column :posts_students, :post_id, :integer, null: false
    change_column :posts_students, :student_id, :integer, null: false

    # Posts tags
    change_column :posts_tags, :post_id, :integer, null: false
    change_column :posts_tags, :tag_id, :integer, null: false

    # Posts teachers
    change_column :posts_teachers, :post_id, :integer, null: false
    change_column :posts_teachers, :teacher_id, :integer, null: false

    # Student mentors
    change_column :student_mentors, :student_id, :integer, null: false
    change_column :student_mentors, :teacher_id, :integer, null: false

    # Student observations
    change_column :student_observations, :student_id, :integer, null: false
    change_column :student_observations, :post_id, :integer, null: false
    change_column :student_observations, :content, :text, null: false

    # Students
    change_column :students, :first_name, :string, limit: 80
    change_column :students, :last_name, :string, null: false, limit: 80
    change_column :students, :mobile, :string, limit: 40
    change_column :students, :home_phone, :string, limit: 40
    change_column :students, :office_phone, :string, limit: 40
    change_column :students, :bloodgroup, :string, limit: 15
    change_column :students, :archived, :boolean, null: false, default: false

    remove_index :students, :first_name
    remove_index :students, :last_name

    # Students groups
    change_column :students_groups, :student_id, :integer, null: false
    change_column :students_groups, :group_id, :integer, null: false

    # Students groups
    change_column :students_guardians, :student_id, :integer, null: false
    change_column :students_guardians, :guardian_id, :integer, null: false
    
    add_index :students_guardians, [:student_id, :guardian_id], unique: true
    add_index :students_guardians, :guardian_id

    # Tags
    change_column :tags, :name, :string, null: false, limit: 50

    remove_index :tags, :name
    add_index :tags, :name, unique: true

    # Teachers
    change_column :teachers, :first_name, :string, limit: 80
    change_column :teachers, :last_name, :string, null: false, limit: 80
    change_column :teachers, :mobile, :string, limit: 40
    change_column :teachers, :home_phone, :string, limit: 40
    change_column :teachers, :office_phone, :string, limit: 40
    change_column :teachers, :archived, :boolean, null: false, default: false

    remove_index :teachers, :first_name
    remove_index :teachers, :last_name

    # Users
    change_column :users, :email, :string, null: false, limit: 60
    change_column :users, :password_hash, :string, limit: 60
    change_column :users, :password_salt, :string, null: false, limit: 60
    change_column :users, :profile_id, :integer, null: false
    change_column :users, :profile_type, :string, null: false, limit: 10

    remove_index :users, :username
    remove_index :users, name: :users_profile_index
    add_index :users, :email, unique: true
    add_index :users, [:profile_type, :profile_id], unique: true
  end

  def down
    create_table :basic_skills do |t|
      t.integer :subject_id
      t.timestamps
    end

    # Comments
    change_column :comments, :post_id, :integer, null: true
    change_column :comments, :author_id, :integer, null: true
    change_column :comments, :author_type, :string, null: true, limit: 10

    remove_index :comments, :created_at

    # Groups
    change_column :groups, :name, :string, null: true
    
    remove_index :groups, :name

    # Guardians
    change_column :guardians, :first_name, :string
    change_column :guardians, :last_name, :string, null: true
    change_column :guardians, :mobile, :string
    change_column :guardians, :home_phone, :string
    change_column :guardians, :office_phone, :string

    remove_index :guardians, [:last_name, :first_name]

    # Images
    change_column :images, :post_id, :integer, null: true

    # Posts
    change_column :posts, :title, :string, null: true
    add_column :posts, :last_commented_at, :datetime
    change_column :posts, :author_id, :integer, null: true
    change_column :posts, :author_type, :string, null: true

    add_index :posts, :last_commented_at
    remove_index :posts, [:author_type, :author_id]
    remove_index :posts, :title

    # Posts students
    change_column :posts_students, :post_id, :integer, null: true
    change_column :posts_students, :student_id, :integer, null: true

    # Posts tags
    change_column :posts_tags, :post_id, :integer, null: true
    change_column :posts_tags, :tag_id, :integer, null: true

    # Posts teachers
    change_column :posts_teachers, :post_id, :integer, null: true
    change_column :posts_teachers, :teacher_id, :integer, null: true

    # Student mentors
    change_column :student_mentors, :student_id, :integer, null: true
    change_column :student_mentors, :teacher_id, :integer, null: true

    # Student observations
    change_column :student_observations, :student_id, :integer, null: true
    change_column :student_observations, :post_id, :integer, null: true
    change_column :student_observations, :content, :text, null: true

    # Students
    change_column :students, :first_name, :string
    change_column :students, :last_name, :string, null: true
    change_column :students, :mobile, :string
    change_column :students, :home_phone, :string
    change_column :students, :office_phone, :string
    change_column :students, :bloodgroup, :string
    change_column :students, :archived, :boolean, null: true
    change_column_default :students, :archived, nil

    add_index :students, :first_name, name: :index_student_profiles_on_first_name
    add_index :students, :last_name, name: :index_student_profiles_on_last_name

    # Students groups
    change_column :students_groups, :student_id, :integer, null: true
    change_column :students_groups, :group_id, :integer, null: true

    # Students groups
    change_column :students_guardians, :student_id, :integer, null: true
    change_column :students_guardians, :guardian_id, :integer, null: true
    
    remove_index :students_guardians, [:student_id, :guardian_id]
    remove_index :students_guardians, :guardian_id

    # Tags
    change_column :tags, :name, :string, null: true, limit: 50

    remove_index :tags, :name
    add_index :tags, :name, name: :index_subjects_on_name

    # Teachers
    change_column :teachers, :first_name, :string
    change_column :teachers, :last_name, :string, null: true
    change_column :teachers, :mobile, :string
    change_column :teachers, :home_phone, :string
    change_column :teachers, :office_phone, :string
    change_column :teachers, :archived, :boolean, null: true
    change_column_default :teachers, :archived, nil

    add_index :teachers, :first_name, name: :index_teacher_profiles_on_first_name
    add_index :teachers, :last_name, name: :index_teacher_profiles_on_last_name

    # Users
    change_column :users, :email, :string, null: true
    change_column :users, :password_hash, :string
    change_column :users, :password_salt, :string, null: true
    change_column :users, :profile_id, :integer, null: true
    change_column :users, :profile_type, :string, null: true

    remove_index :users, :email
    remove_index :users, [:profile_type, :profile_id]
    add_index :users, :email, name: :index_users_on_username
    add_index :users, [:profile_id, :profile_type], name: :users_profile_index
  end
end
