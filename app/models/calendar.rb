class Calendar < ActiveRecord::Base
  
  # Behaviors
  stampable
  acts_as_paranoid

  # Associations
  has_many    :calendar_entries
  
  # Named scopes
  named_scope :ordered, :order => "year DESC"
  named_scope :for_year, lambda { |year| { :conditions => ["year = ?", year] } }
  
  # Triggers
  before_create :apply_defaults
  
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

  def apply_defaults
    self.description = "Quasus global calendar for #{self.year}"
  end
  
  # Abstract methods
  
end
