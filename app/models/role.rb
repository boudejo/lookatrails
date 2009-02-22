class Role < ActiveRecord::Base
 
  # Behaviors

  # Assocations
  has_and_belongs_to_many :users
  # Delegations

  # Named scopes

  # Triggers

  # Defaults

  # Attributes

  # Enums

  # Validations
  validates_presence_of :name, :on => :create

  # Instance methods

  # Abstract methods
end