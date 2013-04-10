class ChangeBirthdayField < ActiveRecord::Migration
  def up
    rename_column :students, :birthday, :birthday_raw
  end

  def down
    rename_column :students, :birthday_raw, :birthday
  end
end
