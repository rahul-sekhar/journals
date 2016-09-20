class NotifyGuardian
  attr_reader :guardian

  def self.notify_all
    Guardian.all.each do |guardian|
      self.new(guardian)
    end
  end

  def initialize(guardian)
    @guardian = guardian
    guardian.students.each do |student|
      for_student(student)
    end
    set_last_notified
  end

  private

  def for_student(student)
    NotifyGuardianForStudent.new(@guardian, student)
  end

  def set_last_notified
    guardian.last_notified = Time.now
    guardian.save!
  end
end