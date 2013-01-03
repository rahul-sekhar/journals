class User < ActiveRecord::Base
  attr_accessible :password, :profile
  attr_accessor :password
  before_save :encrypt_password
  belongs_to :profile, polymorphic: true
  validates :email, presence: true, format: { with: /.+@.+\..+/ }

  def encrypt_password
    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
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
      DELETE FROM users
    SQL

    change_table :users do |t|
      t.remove :role
      t.rename :username, :email
    end

    User.reset_column_information

    n = 1

    Admin.all.each do |admin|
      user = User.new(password: "pass", profile: admin)
      user.email = admin.email if admin.email.present?
      if user.invalid?
        user.email = "filler_#{n}@email.com"
        n+= 1
      end
      user.save!
    end

    Student.all.each do |student|
      user = User.new(password: "pass", profile: student)
      user.email = student.email if student.email.present?
      if user.invalid?
        user.email = "filler_#{n}@email.com"
        n+= 1
      end
      user.save!
    end

    Teacher.all.each do |teacher|
      user = User.new(password: "pass", profile: teacher)
      user.email = teacher.email if teacher.email.present?
      if user.invalid?
        user.email = "filler_#{n}@email.com"
        n+= 1
      end
      user.save!
    end

    Guardian.all.each do |guardian|
      user = User.new(password: "pass", profile: guardian)
      user.email = guardian.email if guardian.email.present?
      if user.invalid?
        user.email = "filler_#{n}@email.com"
        n+= 1
      end
      user.save!
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
