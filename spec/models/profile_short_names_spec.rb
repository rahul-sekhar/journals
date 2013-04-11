require 'spec_helper'

describe 'updating of profile short_names' do
  let(:student) { create(:student, name: "One Two") }
  let(:teacher) { create(:teacher, name: "Three Four") }
  let(:guardian) { create(:guardian, students: [student], name: "Five Six") }

  before do
    student
    teacher
    guardian
  end

  it 'automatically sets short names' do
    student.reload.short_name.should == 'One'
    teacher.reload.short_name.should == 'Three'
    guardian.reload.short_name.should == 'Five'
  end

  describe 'when a profile with a duplicate first name is created' do
    before do
      @new_student = create(:student, name: "Three New")
    end

    it 'updates conflicting short names, using initials' do
      student.reload.short_name.should == 'One'
      teacher.reload.short_name.should == 'Three F.'
      guardian.reload.short_name.should == 'Five'
      @new_student.reload.short_name.should == 'Three N.'
    end

    describe 'when the name is changed' do
      before do
        @new_student.name = 'Five New'
        @new_student.save!
      end

      specify 'all short names are updated' do
        student.reload.short_name.should == 'One'
        teacher.reload.short_name.should == 'Three'
        guardian.reload.short_name.should == 'Five S.'
        @new_student.reload.short_name.should == 'Five N.'
      end
    end

    describe 'when the profile is deleted' do
      before do
        @new_student.destroy
      end

      specify 'all short names are updated' do
        student.reload.short_name.should == 'One'
        teacher.reload.short_name.should == 'Three'
        guardian.reload.short_name.should == 'Five'
      end
    end

    describe 'when another profile is added with a conflicting first name and initial' do
      before do
        @new_guardian = create(:guardian, students: [@new_student], name: "Three Fiddy")
      end

      specify 'all short names are updated' do
        student.reload.short_name.should == 'One'
        teacher.reload.short_name.should == 'Three Four'
        guardian.reload.short_name.should == 'Five'
        @new_student.reload.short_name.should == 'Three N.'
        @new_guardian.reload.short_name.should == 'Three Fiddy'
      end
    end
  end

end