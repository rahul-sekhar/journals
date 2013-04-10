class AddUnderscoreToBloodgroup < ActiveRecord::Migration
  def up
    rename_column :students, :bloodgroup, :blood_group
  end

  def down
    rename_column :students, :blood_group, :bloodgroup
  end
end
