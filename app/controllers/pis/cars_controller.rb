class Pis::CarsController < ApplicationController
  resource_controller
  before_filter :login_required
  add_crumb("Cars") { |instance| instance.send :collection_path }
  
  # CUSTOMIZE
    [new_action, create].each{|action|
      action.before do
        add_crumb("New "+object.class.to_s, new_object_path)
      end
    }
    
    [edit, update].each {|action|
      action.before do
        add_crumb(object.to_s, edit_object_path)
      end
    }
  
    show.before do
      add_crumb(object.to_s, object_path)
    end
    
    show.failure.wants.html { redirect_to url_for(dashboard_path) }
  
    destroy.before do
      begin
        @object.unassign
      rescue AASM::InvalidTransition
        flash[:notice] = "Error occured while changing status." 
      end
    end
  
  private
  
    def collection
      @search = params[:search]
      @page = params[:page]
      @collection ||= end_of_association_chain.search(@search).ordered.paginate(:page => @page)
    end

end
