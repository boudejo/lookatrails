class Person < ActiveRecord::Base
  
  # Behaviors
  stampable
  acts_as_paranoid
  
  # Associations
  belongs_to  :identity, :polymorphic => true
  has_one     :address, :as => :addressable
  has_many    :communication_options, :class_name => 'Communication', :as => :communicatable, :attributes => true

  # Delegations

  # Named scopes
  
  # Triggers
  before_create     :apply_defaults
  after_validation  :collect_association_errors
  after_save        :process_assocation_updates
  
  def apply_defaults
    if self.identity.nil? then
      self.address = Address.new({:label => 'home'})
      self.communication_options = Communication.defaults(self.default_communication_settings)
    end
  end
  
  def process_assocation_updates
    # Asset folders
    if saved? then
      if self.fullname_changed? then
        if self.identity.respond_to?(:asset_folder) then
          self.identity.change_asset_folder(fullname_was, fullname)
        end
      end
      if self.changed? && self.identity.respond_to?(:execute_assoc_callback) then
        self.identity.execute_assoc_callback(self.changes?, self)
      end
    end
  end
  
  # Defaults

  # Attributes
  
  # Enums
  MARITALSTATUSES = [:unspecified, :maried, :unmarried, :divorced, :living_together]
  define_enum :marital_status, nil, :default => :unspecified
  
  # Validations
  validates_presence_of     :first_name
  validates_format_of       :first_name,    :with => /\A[^[:cntrl:]\\<>\/&]*\z/ ,  :message => "avoid non-printing characters and \\&gt;&lt;&amp;/ please.".freeze, :allow_nil => true
  validates_length_of       :first_name,    :maximum => 100

  validates_presence_of     :last_name 
  validates_format_of       :last_name,     :with => /\A[^[:cntrl:]\\<>\/&]*\z/ ,  :message => "avoid non-printing characters and \\&gt;&lt;&amp;/ please.".freeze, :allow_nil => true
  validates_length_of       :last_name,     :maximum => 100
  
  def validate
    if !new_record? then
      self.communication_options.each do |communication| 
        communication.valid?
        if !communication.errors.empty? then
          self.errors.add("communication_options", "is invalid")
          return false
        end
      end
    end
  end
    
  # Instance Methods
  def to_s(type = 'fullname')
    case type.to_s
      when 'fullname'
        fullname
      else
        super()
    end
  end
  
  def presenter
    PersonProfile.new(:person => self, :address => self.address)
  end
  
  def fullname
     "#{self.last_name} #{self.first_name}"
  end
  
  def fullname_changed?
    (last_name_changed? || first_name_changed?) ? true : false
  end
  
  def fullname_was
     "#{self.last_name_was} #{self.first_name_was}"
  end
  
  def default_communication_settings
    {:defaults => [:phone, :cell, :email], :editable => false, :deleteable => false, :label => 'Home'}
  end
    
  # Abstract methods
  
end