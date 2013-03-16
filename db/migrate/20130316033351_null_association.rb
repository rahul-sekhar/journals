class NullAssociation < ActiveRecord::Migration
  def up
    create_table :null_table do |t|
      t.integer :foreign_id
    end
  end

  def down
    drop_table :null_table
  end
end
