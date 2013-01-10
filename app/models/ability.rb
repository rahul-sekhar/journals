class Ability
  include CanCan::Ability

  def initialize(user)
    profile = user.profile

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
      can :manage, Post, author_id: student.id, author_type: "Student"

    elsif user.is_guardian?
      guardian = profile

      # Can read posts one of their students is tagged in, that they have permission to see or that they authored
      can :read, Post, Post.readable_by_guardian(guardian) do |post|
        post.author == guardian ||
        (post.visible_to_guardians && (post.students & guardian.students).present?)
      end

      # Can create, update and destroy posts that they authored
      can [:create, :update, :destroy], Post, author_id: guardian.id, author_type: "Guardian"

      # Can edit its students pages
      can :update, Student do |student|
        guardian.students.exists? student
      end

      # Can edit the pages of guardians who share any of its students
      can :update, Guardian do |other_guardian|
        (guardian.students & other_guardian.students).present?
      end
    end

    # Everyone can read all comments on posts they can read
    can :read, Comment

    # Everyone can manage comments that they authored
    can :manage, Comment, author_id: user.profile_id, author_type: user.profile_type

    # Everyone can view all profiles
    can :read, Student
    can :read, Teacher
    can :read, Guardian

    # Everyone can view all groups
    can :read, Group

    # Everyone can edit their own profile
    can :update, profile
  end
end
