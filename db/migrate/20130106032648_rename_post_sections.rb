class RenamePostSections < ActiveRecord::Migration
  def up
    rename_table :post_sections, :student_observations
  end

  def down
    rename_table :student_observations, :post_sections
  end
end
