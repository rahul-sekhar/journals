class DbChanges < ActiveRecord::Migration
  def up
    change_column :strands, :name, :string, null: false
  end

  def down
    change_column :strands, :name, :string, null: false
  end
end
