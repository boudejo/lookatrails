class EmployeeProfile < ActivePresenter::Base
  presents :employee, :address, :person
  
  before_save :assign_address_to_employee, :assign_person_to_employee
  after_save :assign_employee_to_person
    
  def assign_address_to_employee
    if !@employee.saved? then
      @address.main = true
      @address.addressable = @employee
      @employee.address = nil
    end
  end
  
  def assign_person_to_employee
    if !@employee.saved? then
      @employee.identity = @person
    end
  end
  
  def assign_employee_to_person
    @person.identity = @employee
    @person.save
  end
  
  def communication_attributes=(*args)
    @employee.communication_options_attributes = args[0]
  end 
  
  def save
    ActiveRecord::Base.transaction do
      super
    end
  end
  
  # Instance Methods
  def to_s(type = '')
    case type
      when "full"
        @employee.to_s('fullname')
      else
        @employee.id
    end     
  end
  
end