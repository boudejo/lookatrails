class ResourcesController < ApplicationController
   resource_controller
   before_filter :login_required, :is_valid_action?
   actions :all
   
   # CUSTOMIZE
   index.wants.html { render :template => 'resources/index' }
   new_action.wants.html { render :template => 'resources/new' }
   create do
     wants.html { 
       rebuild_object
       render :template => 'resources/new' 
     }
     vfails.wants.html { 
       render :template => 'resources/new' }
     failure.wants.html { 
       render :template => 'resources/new' 
     }
   end
   edit.wants.html { render :template => 'resources/edit' }
   
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
