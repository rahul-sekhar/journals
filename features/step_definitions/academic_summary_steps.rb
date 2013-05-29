Given(/^I teach some students with academic work done$/) do
  @subject1 = FactoryGirl.create(:subject, name: "Maths")
  @subject2 = FactoryGirl.create(:subject, name: "English")
  @subject3 = FactoryGirl.create(:subject, name: "Psychology")

  @student1 = create_profile('student', 'John Doe')
  @student2 = create_profile('student', 'William Tell')
  @student3 = create_profile('student', 'Tyler Dunham')

  @st1 = @subject1.add_teacher(@profile)
  @st2 = @subject2.add_teacher(@profile)

  @st1.students << [@student1, @student3]
  @st2.students << [@student2, @student3]

  FactoryGirl.create(:unit, student: @student1, subject: @subject1, name: "Test unit", due: Date.new(2010, 10, 2))
  FactoryGirl.create(:unit, student: @student2, subject: @subject1, name: "Other unit")

  strand = @subject2.add_strand('Strand')
  milestone = strand.add_milestone(1, 'Some milestone')
  FactoryGirl.create(:student_milestone, student: @student2, milestone: milestone, updated_at: Date.new(2009, 1, 1))
end