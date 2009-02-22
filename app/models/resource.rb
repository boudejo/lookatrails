class Resource < ActiveRecord::Base
  
  # Behaviors
  stampable
  acts_as_paranoid
  
  # Associations
  belongs_to :opportunity, :counter_cache => true
  belongs_to :project, :counter_cache => true
  belongs_to :employee
  
  # Delegations

  # Named scopes

  # Triggers
  
  # Defaults
  
  # Attributes
  
  # Enums
  
  # Validations
  validates_associated      :opportunity, :project
    
  validates_presence_of     :employee_id, :message => "^An employee must be selected before a resource can be added."
  validates_associated      :employee  
    
  def validate
    if new_record? then
      puts 'RECORD IS:'+self.inspect
      #Resource.exists?(5)
      #Resource.exists?(:employee_id => self.employee_id)
      if (self.employee_id && self.opportunity_id) && !self.project_id then
        if Resource.exists?(['employee_id = ? AND opportunity_id = ?', self.employee_id, self.opportunity_id]) then
          errors.add_to_base('^Consultant is already added to the shortlist of the opportunity. Please select another consultant.')
        end
      end
      
      #http://api.rubyonrails.org/classes/ActiveRecord/Base.html => exists?
    end
  end  
    
  # Instance Methods
  def to_s(type = '')
    case type
      when ''
        super()
      else
        super()
    end
  end
  
  # Abstract methods
  
end
