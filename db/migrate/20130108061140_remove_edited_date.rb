class RemoveEditedDate < ActiveRecord::Migration
  def up
    remove_column :posts, :edited_at
    remove_column :comments, :edited_at
  end

  def down
    add_column :posts, :edited_at, :datetime
    add_column :comments, :edited_at, :datetime
  end
end
