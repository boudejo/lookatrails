class Car < ActiveRecord::Base
  
  # Behaviors
  stampable
  acts_as_paranoid
  
  # Associations
  belongs_to :employee
  
  # Delegations

  # Named scopes
  named_scope :ordered, :order => "license_plate ASC"
  
  # Triggers
  
  # Defaults

  # Attributes
  # Per page pagination
  cattr_reader :per_page
  @@per_page = 50
  
  # Enums
  STATUSES = [:unassigned, :in_use, :out_of_use]
  define_enum :status, nil, :default => :unassigned,
              :depend => {}

  

  # Validations
  validates_presence_of     :license_plate, :brand, :budget
  validates_uniqueness_of   :license_plate
  
  validates_date            :in_service_date, :allow_blank => true
  
  validates_enum            :status
  
  # State machine
  include AASM
  aasm_column :status
  aasm_initial_state :initial => :unassigned
  aasm_state :unassigned
  aasm_state :assigned
  aasm_state :out_of_use

  aasm_event :unassign do
    transitions :to => :unassigned, :from => STATUSES
  end
  
  aasm_event :assign do
    transitions :to => :assigned, :from => :unassigned
  end
  
  aasm_event :out_of_use do
    transitions :to => :out_of_use, :from => [:unassigned, :assigned]
  end

  def aasm_event_fired(from, to)
    case to
      when :unassigned
        if from == :assigned
          puts 'It was assigned so unassign the user'
        end
    end
    puts 'AN AASM EVENT HAS BEEN FIRED => '+from.to_s+' to '+to.to_s
  end
  
  def aasm_event_failed(event)
    puts 'AN AASM EVENT FAILED => ' +event.to_s
  end
  
  # Instance Methods
  def to_s(type = 'full')
    if !new_record?
      default = self.license_plate + ' - ' + self.brand
      case type
        when "full"
          "#{self.class.to_s}: #{default}"
        when "status"
          emp_code = (!self.employee.nil? && self.status_is_in_use?) ? "to #{self.employee_code}" : ''
        else
          super()
      end
    end
  end
  
  # Abstract methods
  def self.search(params)
    scoped do
      brand =~ TW::Search.format_like(params[:brand]) if params && !params[:brand].blank?
      license_plate.sql("LIKE BINARY UPPER(?)", TW::Search.format_like(params[:license_plate])) if params && !params[:license_plate].blank?
    end
  end
 
end
