class Ability
  include CanCan::Ability

  def initialize(user)
    if user.is_teacher?

      # Can manage everything
      can :manage, :all
    
    elsif user.is_student?
      student = user.profile

      # Can read posts they are tagged in
      can :read, Post, students: { id: student.id }

      # Cannot read posts without student permissions
      cannot :read, Post, visible_to_students: false

      # Can manage posts that they authored
      can :manage, Post, user_id: user.id

    elsif user.is_guardian?
      guardian = user.profile
      students = guardian.students

      # Can read posts one of their students is tagged in, that they have permission to see or that they authored
      can :read, Post, Post.readable_by_guardian(guardian) do |post|
        post.user == user ||
        (post.visible_to_guardians && (post.students & students).present?)
      end

      # Can create, update and destroy posts that they authored
      can [:create, :update, :destroy], Post, user_id: user.id
    end

    # Everyone can read all comments on posts they can read
    can :read, Comment

    # Everyone can manage comments that they authored
    can :manage, Comment, user_id: user.id
  end
end
