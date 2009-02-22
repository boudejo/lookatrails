class Crm::DocumentsController < DocumentsController
  belongs_to :account, :opportunity
end