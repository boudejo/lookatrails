class Timesheet < ActiveRecord::Base

  # Behaviors
  stampable
  acts_as_paranoid

  # Associations
  belongs_to  :employee
  has_many    :timesheet_entries
  
  # Delegations
  
  # Named scopes
  named_scope :for_employee_and_year, lambda { |employee_id, year| { :conditions => ["employee_id = ? AND year = ?", employee_id, year] } }
  
  # Triggers
  before_create :apply_defaults
  
  def apply_defaults(workshedule = nil)
    workshedule ||= self.employee.workshedule
    self.default_leave_days = APP.setting('data.leave.default.'+workshedule)
    self.description = 'Timesheet calendar 2009 for employee: '+self.employee.to_s
  end
  
  # Defaults

  # Attributes

  # Enums

  # Validations
  
  # Instance Methods
  def to_s(type = 'current')
    case type.to_s
      when "current"
        
      else
        super()
    end
  end
  
  # Abstract methods
  
end
