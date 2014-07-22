class NotifyGuardianForStudent
  attr_reader :guardian, :student, :posts, :subjects, :comments

  def initialize(guardian, student)
    @guardian = guardian
    @student = student

    check_posts
    check_comments
    check_subjects
    send_notifications
  end

  private

  def send_notifications
    if guardian.email.present? && guardian.active? && (posts.present? || subjects.present? || comments.present?)
      notifications = NotificationSorter.new(self)
      puts "Sending notifications for guardian: #{guardian.name}, student: #{student.name}"
      NotificationMailer.notify_guardian_for_student(notifications).deliver
    end
  end

  def visible_posts
    student.tagged_posts.where(visible_to_guardians: true)
  end

  def check_posts
    @posts = visible_posts
      .where('created_at > ?', guardian.last_notified)
      .where(author_type: 'Teacher')
      .order(:created_at).reverse_order
  end

  def check_comments
    post_ids = visible_posts.map(&:id)
    @comments = Comment
      .where(post_id: post_ids)
      .where('created_at > ?', guardian.last_notified)
      .where{ (author_id != my{guardian}.id) | (author_type != 'Guardian') }
      .order(:created_at).reverse_order
  end

  def check_subjects
    @subjects = (check_units + check_milestones).uniq
  end

  def check_units
    student.units
      .where('updated_at > ?', guardian.last_notified)
      .map(&:subject)
  end

  def check_milestones
    student.student_milestones
      .where('updated_at > ?', guardian.last_notified)
      .map(&:subject)
  end
end