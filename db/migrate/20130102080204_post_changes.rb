class PostChanges < ActiveRecord::Migration
  def up
    change_table :posts do |t|
      t.remove :type_name
    end

    drop_table :students_interests
    drop_table :posts_followups

    rename_table :subjects, :tags

    rename_column :posts_subjects, :subject_id, :tag_id
    rename_table :posts_subjects, :posts_tags
  end

  def down
    change_table :posts do |t|
      t.string :type_name
    end

    create_table :students_interests, :id => false do |t|
      t.integer :student_profile_id
      t.integer :subject_id
    end
    add_index :students_interests, [:student_profile_id, :subject_id], :unique => true

    create_table :posts_followups, :id => false do |t|
      t.integer :post_id
      t.integer :teacher_profile_id
    end
    add_index :posts_followups, [:post_id, :teacher_profile_id], :unique => true

    rename_table :tags, :subjects

    rename_column :posts_tags, :tag_id, :subject_id
    rename_table :posts_tags, :posts_subjects
  end
end
