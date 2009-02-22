class Opportunity < ActiveRecord::Base
  
  # Behaviors
  stampable
  acts_as_paranoid
  
  # Associations
  belongs_to :account, :counter_cache => true, :include => :accountcontactcard
  belongs_to :contact, :counter_cache => true
  belongs_to :bdm, :class_name => 'User' 
  belongs_to :project 
  has_many :resources
  has_many :documents, :as => :documentable
  
  # Delegations
  
  # Named scopes
  named_scope :ordered, :order => "probability DESC, created_at DESC"
  
  # Triggers
  after_save :process_folderchange
  
  def process_folderchange
    if self.name_changed? then
      self.change_asset_folder(self.name_was, self.name)
    end
  end

  # Defaults
  default_value_for :account,       Account.new
  default_value_for :contact,       Contact.new
  default_value_for :daily_price,   0.00.to_s(2)
  default_value_for :probability,   0.00.to_s(2)
  default_value_for :costcenter,    'unspecified'
  default_value_for :billingmethod, 'unspecified'
  default_value_for :budget,        0.00.to_s(2)
  default_value_for :option,        'option_1'
  default_value_for :perc_work,     100.00.to_s(2)
  default_value_for :fte,           1
  default_value_for :max_days,      0
  
  # Attributes
  # Per page pagination
  cattr_reader :per_page
  @@per_page = 50
  # Asset folder
  cattr_reader :asset_folder
  @@asset_folder = true
  
  # Enums
  STATUSES = [:pending, :at_client, :lost, :won, :closed]
  define_enum :status, nil, :default => :pending, :text => ['pending', '@ client'], 
              :depend => {:pending => [:at_client], :at_client => [:lost, :won], :lost => [:pending], :won => [], :closed => [:pending]}
              
  COSTCENTERS = APP.setting('data.cost_centers')
  define_enum :costcenter, nil, :default => :unspecified
  
  PROBABILITIES = ['25%', '75%']
  define_enum :probability, nil, :default => '25'
  
  BILLINGMETHODS = [:unspecified, :tm, :fp]
  define_enum :billingmethod, nil, :default => :unspecified, :text => ['-', 'time material', 'fixed price']
  
  OPTIONS = [:option_1, :option_2]
  define_enum :option, nil, :default => :option_1, :text => ['Optie 1', 'Optie 2']
  
  # Validations
  validates_date            :end_date
  validates_date            :start_date
                                          
  validates_presence_of     :account_id, :message => "^An account must be selected before you can save this project"
  validates_associated      :account
    
  validates_presence_of     :name
  validates_format_of       :name,    :with => /\A[^[:cntrl:]\\<>\/&]*\z/ ,  :message => "avoid non-printing characters and \\&gt;&lt;&amp;/ please.".freeze, :allow_nil => true
  validates_length_of       :name,    :maximum => 255
  
  validates_enum            :costcenter
  validates_enum            :billingmethod
  
  def validate
    validate_period(self.start_date, self.end_date)
  end
  
  # State machine
  include AASM
  aasm_column :status
  aasm_initial_state :initial => :pending
  aasm_state :pending
  aasm_state :at_client
  aasm_state :lost
  aasm_state :won, :enter => :do_when_won
  aasm_state :closed

  aasm_event :reopen do
    transitions :to => :pending, :from => [:lost, :closed]
  end

  aasm_event :send_client do
    transitions :to => :at_client, :from => :pending
  end
  
  aasm_event :close_won do
    transitions :to => :won, :from => :at_client
  end
  
  aasm_event :close_lost do
    transitions :to => :lost, :from => :at_client
  end
  
  aasm_event :close do
    transitions :to => :closed, :from => %w(pending at_client).symbolize
  end
  
  def aasm_event_fired(from, to)
    # puts 'AN AASM EVENT HAS BEEN FIRED => '+from.to_s+' to '+to.to_s
  end
  
  def aasm_event_failed(event)
    # puts 'AN AASM EVENT FAILED => ' +event.to_s
  end
  
  def do_when_won
    ActiveRecord::Base.transaction do
      # Create new project
      new_project = Project.new({
        :name         => self.name,
        :account      => self.account,
        :opportunity  => self
      })
      new_project.save
    end
  end
  
  # Instance Methods
  def to_s(type = 'name')
    if !new_record?
      default = self.name.to_s
      case type
        when "full"
          "#{self.class.to_s}: #{default}"
        when "foldername"
          asset_folder_name
        when "name"
          default
        else
          super()
      end
    end
  end
  
  def asset_folder_name(name = nil)
    if name.nil? then
      "#{self.name.downcase.parameterize}_#{self.id.to_s}"
    else
      "#{name.downcase.parameterize}_#{self.id.to_s}"
    end
  end
  
  def is_billingmethod?(a_method)
    return (self.billingmethod == a_method.to_s)
  end
  
  def is_option?(an_option)
    return (self.option == an_option.to_s)
  end
  
  # Abstract methods
  def self.search(params)
    scoped do
      name =~ TW::Search.format_like(params[:name]) if params && params[:name]
      account_id = account.id
    end
  end
end
