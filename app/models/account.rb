class Account < ActiveRecord::Base
  
  # Behaviors
  stampable
  acts_as_paranoid
  
  # Associations
  has_one :accountcontactcard, :dependent => :destroy, :as => :accountcontactable
  has_many :opportunities
  has_many :projects
  has_many :documents, :as => :documentable
  
  # Delegations
  delegate :name, :to => :accountcontactcard
  delegate :address_country, :to => :accountcontactcard
  
  # Named scopes
  named_scope :ordered, :order => "accountcontactcards.first_name, accountcontactcards.last_name"
  named_scope :with_accountcontactcards, :select => 'accounts.*, accountcontactcards.*', :joins => "left join accountcontactcards as accountcontactcards on accountcontactcards.accountcontactable_id = accounts.id and accountcontactcards.accountcontactable_type = 'Account'"

  # Triggers
  after_save :process_folderchange
  
  def process_folderchange
    if !self.accountcontactcard.nil? && self.accountcontactcard.name_changed? then
      self.change_asset_folder(self.accountcontactcard.name_was, self.accountcontactcard.name)
    end
  end
  
  # Defaults
  
  # Attributes
  # Per page pagination
  cattr_reader :per_page
  @@per_page = 50
  # Asset folder
  cattr_reader :asset_folder
  @@asset_folder = true
  
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
          asset_folder_name
        when "name"
          default
        else
          super()
      end
    end
  end
  
  def presenter
    AccountCard.new(:account => self, :accountcontactcard => self.accountcontactcard)
  end
  
  def asset_folder_name(name = nil)
    if name.nil? then
      "#{self.accountcontactcard.name.downcase.parameterize}_#{self.id.to_s}"
    else
      "#{name.downcase.parameterize}_#{self.id.to_s}"
    end
  end
  
  # Abstract methods
  def self.search(params)
    scoped do
      accountcontactcard.first_name =~ TW::Search.format_like(params[:name]) if params && params[:name]
      id == accountcontactcard.accountcontactable_id
    end
  end
  
end
