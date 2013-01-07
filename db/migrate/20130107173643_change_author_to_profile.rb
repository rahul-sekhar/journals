class ChangeAuthorToProfile < ActiveRecord::Migration
  def up
    change_table :posts do |t|
      t.integer :author_id
      t.string :author_type
    end

    change_table :comments do |t|
      t.integer :author_id
      t.string :author_type
    end

    execute <<-SQL
      UPDATE posts SET author_id = users.profile_id, author_type = users.profile_type FROM users WHERE posts.user_id = users.id;
      UPDATE comments SET author_id = users.profile_id, author_type = users.profile_type FROM users WHERE comments.user_id = users.id;
    SQL

    remove_column :posts, :user_id
    remove_column :comments, :user_id
  end

  def down
    change_table :posts do |t|
      t.integer :user_id
    end

    change_table :comments do |t|
      t.integer :user_id
    end

    execute <<-SQL
      UPDATE posts SET user_id = users.id FROM users WHERE posts.author_id = users.profile_id AND posts.author_type = users.profile_type;
      UPDATE comments SET user_id = users.id FROM users WHERE comments.author_id = users.profile_id AND comments.author_type = users.profile_type;
    SQL

    remove_column :posts, :author_id
    remove_column :posts, :author_type
    remove_column :comments, :author_id
    remove_column :comments, :author_type
  end
end
