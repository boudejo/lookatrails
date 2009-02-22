class Address < ActiveRecord::Base
  
  # Behaviors
  stampable
  acts_as_paranoid
  
  # Associations
  belongs_to :addressable, :polymorphic => true, :counter_cache => "addresses_count"
  
  # Delegations

  # Named scopes

  # Triggers
  
  # Defaults
  LABELS = [:home, :work, :other]
  default_value_for :label, "home"
  default_value_for :address_country, "Belgium"
    
  # Instance Methods
  def to_s(type = '')
    case type
      when "label"
        "#{self.label.humanize} address"
      else
        super()
    end
  end
  
  # Abstract methods
  def self.fields
    fields = []
    fields.push({:name => :address_line1, :type => :text, :label => 'Address'})
    fields.push({:name => :address_line2, :type => :text, :label => ''})
    fields.push({:name => :address_nr, :type => :text, :label => 'Nr.'})
    fields.push({:name => :address_bus, :type => :text, :label => 'Box'})
    fields.push({:name => :address_postal, :type => :text, :label => 'Postal'})
    fields.push({:name => :address_place, :type => :text, :label => 'Place'})
    fields.push({:name => :address_country, :type => :select, :label => 'Country'})
    return fields
  end
end
