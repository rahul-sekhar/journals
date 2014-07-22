class Guardian < ActiveRecord::Base
end

class NotifyGuardians < ActiveRecord::Migration
  def up
    add_column :guardians, :last_notified, :datetime

    Guardian.reset_column_information

    current_time = Time.now
    Guardian.all.each do |x|
      x.last_notified = current_time
      x.save!
    end
  end

  def down
    remove_column :guardians, :last_notified
  end
end
