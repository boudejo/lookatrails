class PeopleController < ApplicationController
  resource_controller
  before_filter :login_required, :is_valid_action?
  actions :all, :except => [:index, :new, :create, :destroy]
  
  # CUSTOMIZE
    edit.wants.html { render :template => 'people/edit' }
    update do
      wants.html { render :template => 'people/edit' }
      vfails.wants.html { render :template => 'people/edit' }
      failure.wants.html { render :template => 'people/edit' }
    end
    show.wants.html { render :template => 'people/show' }
  
  protected
  
    def object
      if ['edit', 'update', 'show'].include?(params[:action]) then
         @person ||= parent_object.identity
         if @person then
           @object ||= @person.presenter
           @object  
         else
            redirect_to(object_path)
         end
      end
    end
    
    def object_path
      url_for([namespace, parent_object, 'person'])
    end
    
  private
  
    def model_name
      'PersonProfile'
    end
    
    def update_nochanges?
      false
    end
    
    def is_valid_action?
      if !request.xhr? || !parent_object then
        error
        return false
      end
    end
  
end