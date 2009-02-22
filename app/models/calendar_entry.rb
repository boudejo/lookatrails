class CalendarEntry < ActiveRecord::Base
  
  # Behaviors
  stampable
  acts_as_paranoid
  
  acts_as_enum  :kind, [:workday, :general_leave, :holiday, :postponed_holiday, :event_special_day],{
    :labels       => [nil, 'General leave day'],
    :store_as     => :string
  }

  # Assocations
  belongs_to  :calendar
  
  # Delegations
  

  # Named scopes

  # Triggers

  # Defaults
  default_value_for :kind, :workday
  
  # Attributes

  # Enums
  #KINDS = APP.setting('data.calendar.types.values')
  #define_enum :kind, nil, :default => :W, :text => APP.setting('data.calendar.types.text')
  
  # Validations

  # State machine

  # Instance methods

  # Abstract methods
  
end
