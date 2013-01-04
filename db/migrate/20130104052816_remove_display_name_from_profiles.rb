class RemoveDisplayNameFromProfiles < ActiveRecord::Migration
  def up
    remove_column :students, :display_name
    remove_column :teachers, :display_name
    remove_column :guardians, :display_name
  end

  def down
    add_column :students, :display_name, :string
    add_index :students, :display_name
    add_column :teachers, :display_name, :string
    add_index :teachers, :display_name
    add_column :guardians, :display_name, :string
    add_index :guardians, :display_name
  end
end
