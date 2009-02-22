class Document < ActiveRecord::Base
  
  # Behaviors
  has_attached_file :document,
                    :url  => "/assets/:document_type_foldername/:basenamewithid.:extension",
                    :path => ":rails_root/public/assets/:document_type_foldername/:basenamewithid.:extension"
  # Assocations
  belongs_to :documentable, :polymorphic => true, :counter_cache => "documents_count"
  
  # Delegations

  # Named scopes
  named_scope :ordered, :order => "created_at DESC"
  
  # Triggers

  # Defaults

  # Attributes
  # Per page pagination
  cattr_reader :per_page
  @@per_page = 10
  
  # Enums

  # Validations
  validates_attachment_presence :document, :message => '^ Please select a file before you upload'
  validates_attachment_size :document, :less_than => 5.megabytes
  # validates_attachment_content_type :document, :content_type => ['image/jpeg', 'image/png']

  # Instance methods
  def to_s(type = 'full')
    case type.to_s
      when "full"
        self.document_file_name
      when "foldername"
        self.documentable_type.pluralize.downcase
      when "subject"
        "#{self.class.to_s}: #{self.document_file_name}"
      else
        super()
    end
  end
  
  def type
    self.documentable
  end
  
  # Abstract methods
  
end
