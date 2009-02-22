class RecruitmentProfile < ActivePresenter::Base
  presents :recruitment, :person, :address
  
  before_save :assign_address_to_person, :assign_person_to_recruitment
  
  def assign_address_to_person
    if !@person.saved? then
      @address.main = true
      @address.addressable = @person
    end
  end
  
  def assign_person_to_recruitment
    if !@recruitment.saved? then
      @person.identity = @recruitment
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
        @recruitment.id
    end     
  end
  
end