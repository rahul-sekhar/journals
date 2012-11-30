class Edit < ActiveRecord::Base
  belongs_to :edited_content, polymorphic: true
end

class Post < ActiveRecord::Base
  has_many :edits, as: :edited_content
end

class Comment < ActiveRecord::Base
  has_many :edits, as: :edited_content
end

class SimplifyEdits < ActiveRecord::Migration
  def up
    change_table :posts do |t|
      t.datetime :edited_at
    end

    change_table :comments do |t|
      t.datetime :edited_at
    end

    Post.reset_column_information
    Comment.reset_column_information
    Edit.reset_column_information

    Post.all.each do |post|
      if post.edits.present?
        p "Post #{post.id} has #{post.edits.length} edits"
        last_edit = post.edits.map{ |edit| edit.updated_at }.max
        p "Last edit at #{last_edit}"
        post.edited_at = last_edit
        post.save
      end
    end

    Comment.all.each do |comment|
      if comment.edits.present?
        p "Comment #{comment.id} has #{comment.edits.length} edits"
        last_edit = comment.edits.map{ |edit| edit.updated_at }.max
        p "Last edit at #{last_edit}"
        comment.edited_at = last_edit
        comment.save
      end
    end

    drop_table :edits
  end

  def down
    puts "\t*** Edit data that was lost in this migration cannot be restored ***"

    remove_column :posts, :edited_at
    remove_column :comments, :edited_at

    create_table :edits do |t|
      t.integer  :user_id
      t.references :edited_content, polymorphic: true
      t.timestamps
    end
  end
end
