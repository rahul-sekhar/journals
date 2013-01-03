class RemoveAdmin < ActiveRecord::Migration
  def up
    drop_table :admins
  end

  def down
    create_table :admins do |t|
      t.string   :first_name
      t.string   :last_name
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :display_name
    end
  end
end
