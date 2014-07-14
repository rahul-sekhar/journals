class NotifyGuardian
  attr_reader :students, :guardian

  def self.notify_all
    Guardian.all.each do |guardian|
      self.new(guardian)
    end
  end

  def initialize(guardian)
    @guardian = guardian
    @students = []
    send_notifications
    set_last_notified
  end

  private

  def send_notifications
    check_students
    if students.present? && guardian.email.present?
      puts "Sending notifications for guardian: #{guardian.name}"
      NotificationMailer.notify_guardian(self).deliver
    end
  end

  def check_students
    guardian.students.each do |student|
      check_student(student)
    end
  end

  def check_student(student)
    posts = find_updated_posts(student)
    subjects = find_updated_subjects(student)

    if posts.present? || subjects.present?
      @students.push ({
        student: student,
        posts: posts,
        subjects: subjects
      })
    end
  end

  def find_updated_posts(student)
    student.tagged_posts
      .where('created_at > ?', guardian.last_notified)
      .where(visible_to_guardians: true)
      .where(author_type: 'Teacher')
  end

  def find_updated_subjects(student)
    (find_updated_units(student) + find_updated_milestones(student)).uniq
  end

  def find_updated_units(student)
    student.units
      .where('updated_at > ?', guardian.last_notified)
      .map(&:subject)
  end

  def find_updated_milestones(student)
    student.student_milestones
      .where('updated_at > ?', guardian.last_notified)
      .map(&:subject)
  end

  def set_last_notified
    guardian.last_notified = Time.now
    guardian.save!
  end
end