class Communication < ActiveRecord::Base

  # Behaviors
  
  # Associations
  belongs_to :communicatable, :polymorphic => true, :counter_cache => "communications_count"
  
  # Delegations

  # Named scopes

  # Triggers
  #before_save :apply_settings
  
  def apply_settings
    if !self.communicatable.nil? && self.communicatable.respond_to?(:default_communication_settings) then
      puts 'communicatable settings:'+self.communicatable.send(:default_communication_settings).inspect
    end
  end
  
  # Defaults
  default_value_for :kind,        "other"
  default_value_for :editable,    true
  default_value_for :deleteable,  false
  
  # Attributes

  # Enums
  KINDS = [:phone, :cell, :fax, :email, :im, :skype, :other]
  define_enum :kind, nil, :default => :phone
  
  # Validations
  validates_enum  :kind
  
  validates_presence_of     :value,   :if => :validate_presence_field?
  validates_uniqueness_of   :value,   :if => :validate_unique_field?
  
  # Email specific
  validates_length_of       :value,   :within => 6..100, :allow_blank => true, :if => :email_field?
  validates_format_of       :value,   :with => Authentication.email_regex, :allow_blank => true, :message => Authentication.bad_email_message, :if => :email_field?
  
  def validate
    # custom validation is also possible !!
    # self.errors.add(:value, self.label+' email validation')
  end
  
  def validate_presence_field?
    case self.kind
      when 'email'
        if self.communicatable_type == 'Recruitment' then
          false
        end
      else
        false
    end
  end
  
  def validate_unique_field?
    false
  end
  
  # Instance Methods
  def to_s(type = '')
    case type
      when :name
        'Contactinfo ' + self.label.downcase + ' ' + self.kind.downcase
      else
        super
    end
  end
  
  def email_field?
    (self.kind == 'email')
  end
  
  # Abstract methods
  def self.kinds
    return KINDS
  end
  
  def self.defaults_for(object, opts = {})
    if opts.has_key?(:deleteable) then
      deleteable = opts.delete(:deleteable)
    else
      deleteable = false
    end
    if opts.has_key?(:editable) then
       editable = opts.delete(:editable)
    else
        editable = true
    end
    defaults = opts.delete(:defaults) || nil
    subject = opts.delete(:subject) || nil
    subject_id =  opts.delete(:subject_id) || nil
    label = opts.delete(:label) || nil
    
    if !object.blank? then
      subject = object.class.name
      subject_id = (object.saved?) ? object.id : subject_id
    end
    communications = []
    if defaults.class.name == 'Array' then
      counter = 0
      defaults.each do |k|
        communications.push(Communication.new({:kind => k.to_s, :label => label, :value => '', :desc => '', :rank => counter, :communicatable_id => subject_id, :communicatable_type => subject, :deleteable => deleteable, :editable => editable}))
        counter += 1
      end
    elsif defaults.class.name == 'Hash' then
      counter = 0
      defaults.each do |k, v|
        communications.push(Communication.new({:kind => k.to_s, :label => label, :value => '', :rank => counter, :communicatable_id => subject_id, :communicatable_type => subject, :deleteable => deleteable, :editable => editable}.merge(v)))
        counter += 1
      end
    end
    communications
  end
  
  def self.defaults(opts = {})
    self.defaults_for(nil, opts)
  end
  
  def self.apply_default_settings(communications, settings = nil)
    deleteable = nil
    if settings.has_key?(:deleteable) then
      deleteable = settings[:deleteable]
    end
    editable = nil
    if settings.has_key?(:editable) then
       editable = settings[:editable]
    end
    label = nil
    if settings.has_key?(:label) then
       label = settings[:label]
    end
    communications.each do |communication|
      custom_settings = settings.delete(communication.kind.to_sym) || {}
      if custom_settings.has_key?(:deleteable) then
        communication.deleteable = custom_settings[:deleteable]
      elsif !deleteable.nil? then
        communication.deleteable = deleteable
      end
      if custom_settings.has_key?(:editable) then
        communication.editable = custom_settings[:editable]
      elsif !editable.nil? then
        communication.editable = editable
      end
      if custom_settings.has_key?(:label) then
        communication.label = custom_settings[:label]
      elsif !label.nil? then
        communication.label = label
      end
    end
    communications
  end
  
end
