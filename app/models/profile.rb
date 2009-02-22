class Profile < ActiveRecord::Base
  
  # Behaviors
  stampable
  acts_as_paranoid

  # Associations
  belongs_to :user

  # Delegations

  # Named scopes
  
  # Triggers

  # Defaults
  # These fields in a profile are private, and will not be shown to other users.
  PRIVATE_FIELDS = ["id", "created_at", "updated_at", "deleted_at" "user_id", "creator", "deleter"]
  # These fields in a profile are editable by the user who owns the profile
  USER_FIELDS = ["first_name", "last_name"]
  
  # Attributes

  # Enums
  
  # Validations
  validates_presence_of     :first_name
  validates_format_of       :first_name,    :with => /\A[^[:cntrl:]\\<>\/&]*\z/ ,  :message => "avoid non-printing characters and \\&gt;&lt;&amp;/ please.".freeze, :allow_nil => true
  validates_length_of       :first_name,    :maximum => 100

  validates_presence_of     :last_name 
  validates_format_of       :last_name,     :with => /\A[^[:cntrl:]\\<>\/&]*\z/ ,  :message => "avoid non-printing characters and \\&gt;&lt;&amp;/ please.".freeze, :allow_nil => true
  validates_length_of       :last_name,     :maximum => 100
  
  # Instance Methods
  def to_s(type = '')
    default = fullname.to_s
    case type.to_s
      when "full"
         "#{self.class.to_s}: #{default}"
      when "fullname"
        default
      else
        super()
    end
  end
  
  def fullname
     "#{self.last_name} #{self.first_name}"
  end
  
  # Filter out the private attributes
  def public_attributes
    self.attribute_names.select{|a| !Profile::PRIVATE_FIELDS.include?(a)}
  end
  
  # Filter out the attributes editable by the user
  def user_attributes
    self.attribute_names.select{|a| Profile::USER_FIELDS.include?(a)}
  end
  
  # Abstract methods
  
end