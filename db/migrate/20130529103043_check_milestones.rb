class StudentMilestone < ActiveRecord::Base
  self.table_name = :students_milestones

  def check_if_empty
    if (status == 0 && comments.blank?)
      destroy
    end
  end
end

class CheckMilestones < ActiveRecord::Migration
  def up
    initial_count = StudentMilestone.count

    StudentMilestone.all.each do |milestone|
      milestone.check_if_empty
    end

    number_destroyed = initial_count - StudentMilestone.count
    puts "*** Destroyed #{number_destroyed} student milestones ***"
  end

  def down
  end
end
