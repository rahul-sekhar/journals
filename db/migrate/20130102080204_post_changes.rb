class PostChanges < ActiveRecord::Migration
  def up
    change_table :posts do |t|
      t.remove :type_name
    end
  end

  def down
    change_table :posts do |t|
      t.string :type_name
    end
  end
end
