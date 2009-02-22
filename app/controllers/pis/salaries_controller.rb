class Pis::SalariesController < ApplicationController
  resource_controller
  before_filter :login_required, :is_valid_action?
  belongs_to :employee
  actions :all, :except => [:new]
  
  # CUSTOMIZE
    create do
      wants.json  {
        render_json_results(:success, {}, {:discard_flashes => true, :path => edit_object_path}) 
      }
      vfails.wants.json { render_json_results(:vfails, object, {:discard_flashes => true})  }
      failure.wants.json { render_json_results(:failure, {}, {:discard_flashes => true, :error => 'An unexpected error occured !'}) }
    end
  
    edit.wants.html { render :template => 'pis/salaries/edit' }
    update do
      wants.html { render :template => 'pis/salaries/edit' }
      vfails.wants.html { render :template => 'pis/salaries/edit' }
      nochanges.wants.html { render :template => 'pis/salaries/edit' }
      failure.wants.html { render :template => 'pis/salaries/edit' }
    end
    show.wants.html { render :template => 'pis/salaries/edit' }
  
  private
    
    def collection
      @page = params[:page]
      @collection ||= end_of_association_chain.ordered.paginate(:page => @page)
    end
    
    def is_valid_action?
      if !request.xhr? || !parent_object then
        error
        return false
      end
    end
    
end
