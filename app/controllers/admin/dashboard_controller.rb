class Admin::DashboardController < ApplicationController
  before_filter :login_required
  layout 'admin'
  
  require_role [:admin]
  
  def index
  end
  
end
