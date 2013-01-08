class User < ActiveRecord::Base
  attr_accessible :profile

  belongs_to :profile, polymorphic: true
  validates :email, format: { with: /.+@.+\..+/ }, allow_blank: true

  before_save :set_salt

  def set_salt
    self.password_salt = BCrypt::Engine.generate_salt if password_salt.blank?
  end
end

class Admin < ActiveRecord::Base
end

class Student < ActiveRecord::Base
end

class Teacher < ActiveRecord::Base
end

class Guardian < ActiveRecord::Base
end

class ChangeLoginSystem < ActiveRecord::Migration
  def up
    execute <<-SQL
      DELETE FROM users WHERE role='guardian' OR profile_type='AdminProfile';
      UPDATE users SET profile_type='Student' WHERE profile_type='StudentProfile';
      UPDATE users SET profile_type='Teacher' WHERE profile_type='TeacherProfile';
    SQL

    change_table :users do |t|
      t.remove :role
      t.rename :username, :email
    end

    User.reset_column_information

    User.all.each do |user|
      if user.profile.email.present?
        user.email = user.profile.email
      else
        user.email = nil
      end
      user.save!
    end

    Guardian.all.each do |guardian|
      if guardian.email.present?
        user = User.new(profile: guardian)
        user.email = guardian.email
        user.save
      end
    end

    remove_column :students, :email
    remove_column :teachers, :email
    remove_column :admins, :email
    remove_column :guardians, :email
  end

  def down
    puts "\t*** Username data was lost ***"

    change_table :users do |t|
      t.string :role
      t.rename :email, :username
    end

    add_column :students, :email, :string
    add_column :teachers, :email, :string
    add_column :admins, :email, :string
    add_column :guardians, :email, :string
  end
end
