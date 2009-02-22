class Contact < ActiveRecord::Base
  
  # Behaviors
  stampable
  acts_as_paranoid
    
  # Associations
  has_one :contactcard, :dependent => :destroy, :as => :contactable
  belongs_to :account, :counter_cache => true
  
  # Delegations

  # Named scopes
  named_scope :ordered, :order => "contactcards.first_name, contactcards.last_name"
  
  # Triggers

  # Defaults

  # Attributes
  # Per page pagination
  cattr_reader :per_page
  @@per_page = 50
  
  # Enums

  # Validations
  
  # Instance Methods
  def to_s(type = 'full')
    if !new_record?
      default = self.name.to_s
      case type
        when "full"
          "#{self.class.to_s}: #{default}"
        when "foldername"
          "#{self.name.downcase.parameterize}_#{self.id.to_s}"
        when "name"
          default
        else
          super()
      end
    end
  end
  
  # Abstract methods
  def self.search(params)
    scoped do
      contactcard.first_name =~ TW::Search.format_like(params[:name]) if params && params[:name]
      id == contactcard.contactable_id
    end
  end
end
