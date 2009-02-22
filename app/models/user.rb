require 'digest/sha1'

class User < ActiveRecord::Base
  
  # Behaviors
  model_stamper
  stampable
  acts_as_paranoid
  
  # Associations
  has_and_belongs_to_many :roles
  has_one :profile, :dependent => :destroy
  belongs_to :loginable, :polymorphic => true
  
  # Concerns
  concerned_with :authentication
  
  # Delegations
  delegate :fullname, :to => :profile
   
  # Named scopes
  named_scope :ordered, :order => "users.login ASC"
  named_scope :deleted, :conditions => 'users.deleted_at is NOT NULL', :with_deleted => true
  named_scope :for_role, lambda{ |role|
    {:conditions => ['roles.name LIKE ?', (role.nil? || role.blank?) ? '%' : role]}
  }
  
  # Triggers
  after_create :create_environment
  
  def create_environment
    # Give the default 'user' role
    self.roles << Role.find_by_name('user')
  end
  
  # Defaults

  # Attributes
  # Per page pagination
  cattr_reader :per_page
  @@per_page = 25

  # Enums
  
  # Instance Methods
  def to_s(type = '')
    case type.to_s
      when "mail"
        "#{self.fullname} <#{self.email}>"
      else
        super()
    end
  end
  
  def has_role?(role_in_question = nil)
    @_list ||= self.roles.collect(&:name)
    # System and support accounts have always access
    APP.setting('roles.system').each{|role|
     return true if @_list.include?(role)
    }
    # Check if application user
    APP.setting('roles.application').each{|role|
      return true if @_list.include?(role)
    }
    return true if role_in_question && (@_list.include?(role_in_question.to_s))
  end
  
  def profile_editor?(id)
    !!self.id==id
  end
  
  def manageable_user_roles
  end
  
  # Abstract methods
  def self.search(params)
    scoped do
      login =~ TW::Search.format_like(params[:name]) if params && params[:name]
      id == profile.user_id
    end
  end
  
  def self.system_user
    User.first(:conditions => [ "login = ?", 'system'])
  end  
    
end
