class FrameworkLevels < ActiveRecord::Migration
  def change
    change_table :subjects do |t|
      t.string :column_name, null: false, default: 'Level'
      t.boolean :level_numbers, null: false, default: true
    end
  end
end
