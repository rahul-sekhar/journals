class ArchiveUsers < ActiveRecord::Migration
  def up
    add_column :students, :archived, :boolean
    add_column :teachers, :archived, :boolean
  end

  def down
    remove_column :students, :archived
    remove_column :teachers, :archived
  end
end
