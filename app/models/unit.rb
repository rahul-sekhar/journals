class Unit < ActiveRecord::Base
  attr_accessible :name, :started_date, :due_date, :completed_date, :comments, :student_id, :subject_id

  belongs_to :subject
  belongs_to :student

  validates :name,
    presence: true,
    length: { maximum: 80 }

  validates :subject, presence: true
  validates :student, presence: true

  validates :started, presence: { message: "is invalid" }, if: "started_date.present?"
  validates :due, presence: { message: "is invalid" }, if: "due_date.present?"
  validates :completed, presence: { message: "is invalid" }, if: "completed_date.present?"

  default_scope order{started.desc}

  strip_attributes

  def started_date
    if @started_date.present?
      @started_date
    elsif started.present?
      started.strftime( '%d-%m-%Y' )
    end
  end

  def started_date=(val)
    @started_date = val
    begin
      self.started = Date.strptime( val, '%d-%m-%Y' )
    rescue
      self.started = nil
    end
  end

  def due_date
    if @due_date.present?
      @due_date
    elsif due.present?
      due.strftime( '%d-%m-%Y' )
    end
  end

  def due_date=(val)
    @due_date = val
    begin
      self.due = Date.strptime( val, '%d-%m-%Y' )
    rescue
      self.due = nil
    end
  end

  def completed_date
    if @completed_date.present?
      @completed_date
    elsif completed.present?
      completed.strftime( '%d-%m-%Y' )
    end
  end

  def completed_date=(val)
    @completed_date = val
    begin
      self.completed = Date.strptime( val, '%d-%m-%Y' )
    rescue
      self.completed = nil
    end
  end
end