class StudentMilestone < ActiveRecord::Base
  self.table_name = :students_milestones
end

class MilestoneDates < ActiveRecord::Migration
  def change
    add_column :students_milestones, :date, :datetime
    add_index :students_milestones, :date

    StudentMilestone.reset_column_information
    StudentMilestone.all.each do |x|
      x.date = x.updated_at
      x.save!
    end
  end
end
