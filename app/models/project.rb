class Project < ActiveRecord::Base
  
  # Behaviors
  stampable
  acts_as_paranoid
  
  # Associations
  belongs_to :account, :counter_cache => true, :include => :accountcontactcard
  belongs_to :contact, :counter_cache => true
  has_one :opportunity, :readonly => true
  has_many :resources
  has_many :documents, :as => :documentable
  
  # Delegations

  # Named scopes
  named_scope :ordered, :order => "name"
  named_scope :with_accountcontactcards, :select => 'accounts.*, accountcontactcards.*', :joins => "left join accountcontactcards as accountcontactcards on accountcontactcards.accountcontactable_id = accounts.id and accountcontactcards.accountcontactable_type = 'Account'"
  
  # Triggers
  after_save :process_folderchange
  
  def process_folderchange
    if self.name_changed? then
      self.change_asset_folder(self.name_was, self.name)
    end
  end
  
  # Defaults
  default_value_for :account, Account.new
  
  # Attributes
  # Per page pagination
  cattr_reader :per_page
  @@per_page = 50
  # Asset folder
  cattr_reader :asset_folder
  @@asset_folder = true
  
  # Enums
  
  # Validations
  validates_presence_of     :account_id, :message => "^An account must be selected before you can save this project"
  validates_associated      :account
    
  validates_presence_of     :name
  validates_format_of       :name,    :with => /\A[^[:cntrl:]\\<>\/&]*\z/ ,  :message => "avoid non-printing characters and \\&gt;&lt;&amp;/ please.".freeze, :allow_nil => true
  validates_length_of       :name,    :maximum => 255
  
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
  
  def document_folder(name = nil)
    folder_path = RAILS_ROOT+"/public/assets/#{self.class.to_s.pluralize.downcase}/"
    if name.nil? then
      "#{folder_path}#{self.to_s('foldername')}/"
    else
      "#{folder_path}#{name.downcase.parameterize}_#{self.id.to_s}/"
    end
  end

  # Abstract methods
  def self.search(params)
    scoped do
      project.name =~ TW::Search.format_like(params[:name]) if params && params[:name]
      account_id == account.id
    end
  end
  
end
