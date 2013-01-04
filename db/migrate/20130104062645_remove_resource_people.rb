class RemoveResourcePeople < ActiveRecord::Migration
  def up
    remove_column :posts, :resource_people_restricted
  end

  def down
    add_column :posts, :resource_people_restricted, :boolean, default: false, null: false
    add_index :posts, :resource_people_restricted
  end
end
