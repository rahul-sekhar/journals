class ChangeProfileData < ActiveRecord::Migration
  def up
    change_table :teachers do |t|
      t.rename :phone_numbers, :mobile
      
      t.string :home_phone
      t.string :office_phone

      t.remove :bloodgroup, :date_of_birth, :emergency_contact
    end

    change_table :guardians do |t|
      t.rename :phone_numbers, :mobile
      
      t.string :home_phone
      t.string :office_phone
      t.text :address

      t.remove :relationship
    end

    change_table :students do |t|
      t.rename :phone_numbers, :home_phone
      t.rename :date_of_birth, :birthday

      t.string :mobile
      t.string :office_phone
      
      t.remove :emergency_contact
    end
  end

  def down
    change_table :teachers do |t|
      t.rename :mobile, :phone_numbers
      
      t.remove :home_phone, :office_phone

      t.string :emergency_contact
      t.string :bloodgroup
      t.string :date_of_birth
    end

    change_table :guardians do |t|
      t.rename :mobile, :phone_numbers
      t.remove :home_phone, :office_phone, :address

      t.string :relationship
    end

    change_table :students do |t|
      t.rename :home_phone, :phone_numbers
      t.rename :birthday, :date_of_birth

      t.remove :mobile, :office_phone

      t.string :emergency_contact
    end
  end
end
