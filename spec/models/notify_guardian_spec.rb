require 'spec_helper'

describe NotifyGuardian, :c do
  describe '##notify_all' do
    it 'notifies each guardian' do
      guardian1 = FactoryGirl.create(:guardian)
      guardian2 = FactoryGirl.create(:guardian)

      expect(NotifyGuardian).to receive(:new).with(guardian1)
      expect(NotifyGuardian).to receive(:new).with(guardian2)

      NotifyGuardian.notify_all
    end
  end

  describe '#initialize' do
    let!(:student1){ FactoryGirl.create(:student) }
    let!(:student2){ FactoryGirl.create(:student) }
    let!(:student3){ FactoryGirl.create(:student, guardians: [FactoryGirl.create(:guardian)]) }

    let!(:guardian){ FactoryGirl.create(:guardian, students: [student1, student2]) }

    it 'notifies the guardian for each student' do
      expect(NotifyGuardianForStudent).to receive(:new).with(guardian, student1)
      expect(NotifyGuardianForStudent).to receive(:new).with(guardian, student2)
      NotifyGuardian.new(guardian)
    end

    it 'sets last notified for the guardian' do
      allow(Time).to receive(:now){ DateTime.new(2014, 5, 5) }
      NotifyGuardian.new(guardian)
      expect(guardian.reload.last_notified).to eq DateTime.new(2014, 5, 5)
    end
  end
end