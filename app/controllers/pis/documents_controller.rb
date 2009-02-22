class Pis::DocumentsController < DocumentsController
  belongs_to :recruitment, :employee, :project
end