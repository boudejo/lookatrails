class Accountcontactcard < ActiveRecord::Base

  # Behaviors
  stampable
  acts_as_paranoid
  
  # Associations
  belongs_to :accountcontactable, :polymorphic => true
  
  # Delegations

  # Named scopes

  # Triggers
  
  # Defaults
  default_value_for :address_country, "Belgium"

  # Attributes

  # Enums
    
  # Validations
  validates_presence_of     :first_name
  validates_format_of       :first_name,    :with => /\A[^[:cntrl:]\\<>\/&]*\z/ ,  :message => "avoid non-printing characters and \\&gt;&lt;&amp;/ please.".freeze, :allow_nil => true
  validates_length_of       :first_name,    :maximum => 100

  validates_format_of       :last_name,     :with => /\A[^[:cntrl:]\\<>\/&]*\z/ ,  :message => "avoid non-printing characters and \\&gt;&lt;&amp;/ please.".freeze, :allow_nil => true
  validates_length_of       :last_name,     :maximum => 100
  
  validates_length_of       :email,    :within => 6..100, :allow_nil => true, :allow_blank => true
  validates_uniqueness_of   :email,    :allow_blank => true
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message, :allow_nil => true, :allow_blank => true
  
  # Instance Methods
  def to_s(type = '')
    case type.to_s
      when "fullname"
        fullname
      when "name"
        name
      else
        super()
    end
  end
  
  def fullname
     "#{self.last_name} #{self.first_name}"
  end
  
  def name
    self.first_name
  end
  
  def name_changed?
    first_name_changed?
  end
  
  def name_was
    first_name_was
  end
  
  # Abstract methods
  
end
