class Crm::ContactsController < ApplicationController
  resource_controller
  before_filter :login_required
  add_crumb("Contacts") { |instance| instance.send :collection_path }
  
  # SET FLASHES
  
  # CUSTOMIZE
    show.before do
      add_crumb(object.to_s, object_path)
    end
    
    show.failure.wants.html { redirect_to url_for(dashboard_path) }

  private
    def collection
      @search = params[:search]
      @page = params[:page]
      @collection ||= Contact.search(@search).ordered.paginate(:page => @page)
    end
end
