class Employee < ActiveRecord::Base
  
  # Behaviors
  stampable
  acts_as_paranoid
  
  # Associations
  has_one     :recruitment
  belongs_to  :identity, :class_name => 'Person'
  has_one     :address, :as => :addressable
  has_many    :communication_options, :class_name => 'Communication', :as => :communicatable, :attributes => true
  has_one     :salary, :conditions => ['current = ?', true]
  has_many    :salaries
  has_one     :car
  has_one     :timesheet, :conditions => ['year = ?', Time.now.year]
  has_many    :timesheets
  has_one     :user_account, :class_name => 'User', :as => :loginable
  has_one     :user_profile, :class_name => 'Profile', :through => :user_account
  has_many    :documents, :as => :documentable
  
  # Delegations
  delegate :fullname,     :to => :identity
  delegate :home_address, {:to => :identity, :method => :address}
  
  # Named scopes
  named_scope :ordered, :order => "employees.function, people.last_name, people.first_name"
  
  # Triggers
  after_validation  :collect_association_errors
  before_create     :apply_defaults
  before_save       :update_code
  after_create      :check_calendar_creation
  after_save        :update_leave_for_workshedule
  
  def apply_defaults
    if self.recruitment.nil? then
      self.timesheet.employee = self
      self.salary.employee    = self
    else
      self.communication_options = Communication.defaults(self.default_communication_settings)
    end
  end
  
  def update_code
    self.code = self.code.upcase
    puts 'NEW CODE IS:'+self.to_s('code').inspect
    self.fullcode = self.to_s('code')
  end
  
  def check_calendar_creation
    # TODO: check if current month is 3 months before new year !!
  end
  
  def update_leave_for_workshedule
    if self.workshedule_changed? then
      self.timesheet.default_leave_days = APP.setting('data.leave.default.'+self.workshedule)
      self.timesheet.save
    end
  end
  
  # Defaults
  default_value_for :status,                            'not_active'
  default_value_for :prev_status,                       'not_active'
  default_value_for :function,                          'consultant'
  default_value_for :joblevel,                          'consultant'
  default_value_for :workshedule,                       'fulltime'
  default_value_for :address,                           Address.new({:label => 'work'}.merge(APP.setting('quasus.address')))
  default_value_for :salary,                            Salary.new({:current => true})
  default_value_for :timesheet,                         Timesheet.new({:year => Time.now.year})
  
  # Attributes
  # Per page pagination
  cattr_reader :per_page
  @@per_page = 50
  # Asset folder
  cattr_reader :asset_folder
  @@asset_folder = true
  
  # Enums
  JOBLEVELS = [:unspecified, :junior, :consultant, :senior]
  define_enum :joblevel, nil, :default => :unspecified

  STATUSES = [:not_active, :active, :no_longer_in_service]
  define_enum :status, nil, :default => :not_active, :text => ['Inactive', 'Active', 'No longer in service'], 
              :depend => {}

  WORKSHEDULES = [:fulltime, :parttime]
  define_enum :workshedule, nil, :default => :fulltime            

  # Validations
  validates_presence_of     :code
  validates_length_of       :code, :minimum => 3, :allow_nil => true
  
  validates_uniqueness_of   :fullcode
  
  validates_enum            :status, :if => :saved?
  validates_enum            :joblevel
  
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
  
  # State machine
  include AASM
  aasm_column :status
  aasm_initial_state :initial => :not_active
  aasm_state :not_active, :enter => :do_when_inactive
  aasm_state :active, :enter => :do_when_active
  aasm_state :no_longer_in_service, :enter => :do_when_no_longer_in_service
  
  aasm_event :inactive do
    transitions :to => :not_active, :from => [:active, :no_longer_in_service]
  end
  
  aasm_event :activate do
    transitions :to => :active, :from => [:not_active]
  end
  
  aasm_event :outofservice do
    transitions :to => :no_longer_in_service, :from => [:active, :not_active]
  end
  
  def do_when_inactive
    puts 'DO WHEN NOT ACTIVE'
  end
  
  def do_when_active
    puts 'DO WHEN ACTIVE'
  end
  
  def do_when_no_longer_in_service
    puts 'DO WHEN NO LONGER IN SERVICE'
  end
  
  # Instance Methods
  def to_s(type = 'fullname')
    case type.to_s
      when "fullname"
        fullname
      when 'code'
        if !self.home_address.nil? then
          "#{self.code}[#{self.home_address.address_postal}]"
        else
          "#{self.code}[]"
        end
      when 'postalcode'
        "#{self.home_address.address_postal}" if !self.home_address.nil?
      when "foldername"
         asset_folder_name
      else
        super()
    end
  end
    
  def presenter
    EmployeeProfile.new(:employee => self, :person => self.identity, :address => self.address)
  end
  
  def asset_folder_name(name = nil)
    if name.nil? then
      "#{fullname.downcase.parameterize}_#{self.id.to_s}"
    else
      "#{name.downcase.parameterize}_#{self.id.to_s}"
    end
  end
  
  def default_communication_settings
    {:defaults => [:phone, :cell, :email], :editable => false, :deleteable => false, :label => 'Work'}
  end
    
  # Abstract methods
  def self.search(params)
    scoped do
      any do
        identity.first_name.contains_binary? TW::Search.format_like(params[:name]) if params && !params[:name].blank?
        identity.last_name.contains_binary? TW::Search.format_like(params[:name]) if params && !params[:name].blank?
      end
      identity_id = identity.id # needed if no search is provided and association is used for display
    end
  end

  def self.filter_consultants(params)
    scoped do
      any do
        identity.first_name.contains_binary? TW::Search.format_like(params[:name_or_code]) if params && !params[:name_or_code].blank?
        identity.last_name.contains_binary? TW::Search.format_like(params[:name_or_code]) if params && !params[:name_or_code].blank?
        fullcode.contains_binary? TW::Search.format_like(params[:name_or_code]) if params && !params[:name_or_code].blank?
      end
      identity_id = identity.id # needed if no search is provided and association is used for display
    end
  end

end
