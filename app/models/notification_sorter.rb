class NotificationSorter
  attr_reader :notifications, :guardian, :student

  def initialize(source)
    @notifications = []
    @guardian = source.guardian
    @student = source.student

    source.posts.each{ |x| add_post(x) }
    source.comments.each{ |x| add_comment(x) }
    source.subjects.each{ |x| add_subject(x) }

    @notifications.sort_by!{ |x| x[:time] }.reverse!
  end

  private

  def add_post(post)
    @notifications.push(
      time: post.created_at,
      object: post
    )
  end

  def add_comment(comment)
    @notifications.push(
      time: comment.created_at,
      object: comment
    )
  end

  def add_subject(subject)
    milestones = subject.student_milestones.where(student: student)
    milestone_time = milestones.order(:updated_at).reverse_order.first.try(:updated_at)
    units = subject.units.where(student: student)
    unit_time = units.order(:updated_at).reverse_order.first.try(:updated_at)
    time = [milestone_time, unit_time].max

    @notifications.push(
      time: time,
      object: subject
    )
  end
end