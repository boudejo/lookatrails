class Contactcard < ActiveRecord::Base
  
  # Behaviors
  stampable
  acts_as_paranoid
  
  # Associations
  belongs_to  :contactable, :polymorphic => true
  #has_many    :properties
  #has_one     :primary_address, :class_name => 'Address', :as => :addressable, :conditions => ['accept = ?', true]
  #has_many    :addresses, :as => :addressable, :conditions => ['main != ?', true]
  #has_many    :contact_options, :class_name => 'Communication', :as => :communicatable
  
  # Delegations

  # Named scopes

  # Triggers
  
  # Defaults
=begin
  DEFAULT_PROPERTIES = {
    :first_name => {:label => :first_name, :default_value => '', :validations => {}, :deleteable => false, :rank => 1}
    :last_name => {:label => :last_name, :default_value => '', :validations => {}, :deleteable => false, :rank => 2}
  }
=end
  
  # Attributes

  # Enums
  
  # Validations
  def validate
    
  end
  
  # Instance Methods
  def to_s(type = '')
  end
  
  def properties
    return self.DEFAULT_PROPERTIES
  end
  
  # Abstract methods
  
end
