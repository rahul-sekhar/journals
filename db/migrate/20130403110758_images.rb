class Images < ActiveRecord::Migration
  def up
    change_column :images, :post_id, :integer, null: true
  end

  def down
    change_column :images, :post_id, :integer, null: false
  end
end
