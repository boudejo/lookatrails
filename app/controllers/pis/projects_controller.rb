class Pis::ProjectsController < ApplicationController
  resource_controller
  before_filter :login_required
  add_crumb("Projects") { |instance| instance.send :collection_path }
  actions :all, :except => [:new, :create]
  
  # CUSTOMIZE
    show.before do
      add_crumb(object.name, object_path)
    end
    
    show.failure.wants.html { redirect_to url_for(dashboard_path) }
    
    [edit, update].each {|action|
      action.before do
        add_crumb(object.name, edit_object_path)
      end
    }
  
  private
    
    def collection
      @search = params[:search]
      @page = params[:page]
      #@collection ||= Project.search(@search).with_contactcards.ordered.paginate(:page => @page)
      @collection ||= Project.search(@search).ordered.paginate(:page => @page)
    end
    
end
