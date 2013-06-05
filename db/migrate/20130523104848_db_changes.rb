class StudentMilestone < ActiveRecord::Base
  self.table_name = :students_milestones
end

class Milestone < ActiveRecord::Base
  has_many :student_milestones, dependent: :destroy
end

class Strand < ActiveRecord::Base
  has_many :child_strands, foreign_key: :parent_strand_id, class_name: Strand, dependent: :destroy
  has_many :milestones, dependent: :destroy
end

class DbChanges < ActiveRecord::Migration
  def up
    s_initial_count = Strand.count
    m_initial_count = Milestone.count
    sm_initial_count = StudentMilestone.count

    Strand.all.each do |strand|
      if strand.name.length > 80
        strand.destroy
      end
    end

    s_number_destroyed = s_initial_count - Strand.count
    m_number_destroyed = m_initial_count - Milestone.count
    sm_number_destroyed = sm_initial_count - StudentMilestone.count
    puts "*** Destroyed #{s_number_destroyed} strands, #{m_number_destroyed} milestones, #{sm_number_destroyed} student milestones ***"

    change_column :strands, :name, :string, null: false, limit: 80
  end

  def down
    change_column :strands, :name, :string, null: false
  end
end
