class AddNotesToProfiles < ActiveRecord::Migration
  def up
    add_column :guardians, :additional_emails, :string, limit: 100
    add_column :students, :additional_emails, :string, limit: 100
    add_column :teachers, :additional_emails, :string, limit: 100

    add_column :guardians, :notes, :text
    add_column :students, :notes, :text
    add_column :teachers, :notes, :text
  end

  def down
    remove_column :guardians, :additional_emails
    remove_column :students, :additional_emails
    remove_column :teachers, :additional_emails

    remove_column :guardians, :notes
    remove_column :students, :notes
    remove_column :teachers, :notes
  end
end
