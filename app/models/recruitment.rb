class Recruitment < ActiveRecord::Base
  
  # Behaviors
  stampable
  acts_as_paranoid
  
  # Associations
  belongs_to  :employee
  has_one     :identity, :class_name => 'Person', :as => :identity
  has_many    :documents, :as => :documentable
  
  # Delegations
  delegate :fullname, :address, :to => :identity
  
  # Named scopes
  named_scope :ordered, :order => "recruitments.joblevel, recruitments.status, people.last_name, people.first_name"
  named_scope :joblevel, lambda{ |joblevel|
    {:conditions => ['recruitments.joblevel = ?', joblevel]}
  }
  named_scope :status, lambda{ |status|
    {:conditions => ['recruitments.status = ?', status]}
  }
  named_scope :forecast_ordered, :order => "recruitments.joblevel, recruitments.status, recruitments.created_at DESC"
  
  # Filters
  named_scope :filter_this_month,   lambda { { :conditions => ["recruitments.created_at >= ? and recruitments.created_at <= ?", Date.today.at_beginning_of_month, Date.today.at_end_of_month] } }
  named_scope :filter_last_month,   lambda { { :conditions => ["recruitments.created_at >= ? and recruitments.created_at <= ?", Date.today.at_beginning_of_month << 1, Date.today.at_end_of_month << 1] } }
  
  # Triggers
  
  # Defaults
  default_value_for :status,      'first_stage'
  default_value_for :prev_status, ''
  default_value_for :joblevel,    'unspecified'
  default_value_for :rejected_by, 'unspecified'
  
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
  
  STATUSES = [:first_stage, :second_stage, :joboffer, :joboffer_signed, :rejected]
  define_enum :status, nil, :default => :first_stage, :text => ['1st stage', '2nd stage'], 
              :depend => {:first_stage => [:second_stage, :rejected], :second_stage => [:joboffer, :rejected], :joboffer => [:joboffer_signed, :rejected], :joboffer_signed => [], :rejected => []}
              
  REJECTEDBY = [:unspecified, :quasus, :consultant]
  define_enum :rejected_by, nil, :default => :unspecified, :enum => :rejectedby
  
  # Validations
  validates_enum  :joblevel
  validates_enum  :status, :rejected_by,    :if => :saved?
  
  # State machine
  include AASM
  aasm_column :status
  aasm_initial_state :initial => :first_stage
  aasm_state :first_stage
  aasm_state :second_stage
  aasm_state :joboffer
  aasm_state :joboffer_signed, :enter => :do_when_signed
  aasm_state :rejected
  
  aasm_event :signed do
    transitions :to => :joboffer_signed, :from => :joboffer
  end
  
  aasm_event :reject do
    transitions :to => :rejected, :from => (STATUSES.stringify - %w(rejected)).symbolize
  end
  
  def do_when_signed
    ActiveRecord::Base.transaction do
      # Create new employee
      new_employee = Employee.new({
          :identity               => self.identity,
          :code                   => self.to_s('code'),
          :fullcode               => self.to_s('fullcode'),
          :joblevel               => self.joblevel,
          :recruitment            => self
      })
      new_employee.save
    end
  end
  
  # Instance Methods
  def to_s(type = 'fullname')
    case type.to_s
      when 'fullname'
        fullname
      when 'code'
        "#{self.identity.first_name[0,3].upcase}"
      when 'fullcode'
        self.to_s('code')+"[#{self.address.address_postal}]"
      when 'foldername'
         asset_folder_name
      when 'signed'
         "#{fullname} (#{self.status_change_at.strftime('%d/%m/%Y')})"
      when 'rejected'
        if self.rejected_by == 1 then
          "#{fullname} (Q)"
        elsif self.rejected_by == 2 then
          "#{fullname} (C)"
        else
          "#{fullname}"
        end
      else
        super()
    end
  end
  
  def presenter
    RecruitmentProfile.new(:recruitment => self, :person => self.identity, :address => self.identity.address)
  end
  
  def asset_folder_name(name = nil)
    if name.nil? then
      "#{fullname.downcase.parameterize}_#{self.id.to_s}"
    else
      "#{name.downcase.parameterize}_#{self.id.to_s}"
    end
  end
  
  # Abstract methods
  def self.search(params)
    scoped do
      any do
        identity.first_name.contains_binary? TW::Search.format_like(params[:name]) if params && !params[:name].blank?
        identity.last_name.contains_binary? TW::Search.format_like(params[:name]) if params && !params[:name].blank?
      end
      id == identity.identity_id if !params # needed if no search is provided and association is used for display
    end
  end
    
end