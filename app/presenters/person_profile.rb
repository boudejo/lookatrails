class PersonProfile < ActivePresenter::Base
  presents :person, :address
  
  before_save :assign_address_to_person
  after_save :update_employee_code
  
  def assign_address_to_person
    if !@person.saved? then
      @address.main = true
      @address.addressable = @person
    end
  end
  
  def update_employee_code
    if @address.label == 'home' then
      case @person.identity.class.name
        when 'Recruitment'
          if @person.identity.employee then
            @person.identity.employee.save
          end
        when 'Employee'
          @person.identity.save
      end
    end
  end
  
  def communication_attributes=(*args)
    @person.communication_options_attributes = args[0]
  end
  
  # Instance Methods
  def to_s(type = '')
    case type
      when "full"
        @person.to_s('fullname')
      else
        @person.id
    end     
  end
  
end