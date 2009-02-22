class Crm::OpportunitiesController < ApplicationController
  resource_controller
  before_filter :login_required
  belongs_to :account, :contact
  add_crumb("CRM Opportunities") { |instance| instance.send :collection_path }
  
  # CUSTOMIZE
    new_action.before do
       add_crumb("New "+object.class.to_s, new_object_path)
       load_related_objects(:account)
    end
    
    create.before do
       add_crumb("New "+object.class.to_s, new_object_path)
       load_related_object(:account, {:param => params[:opportunity][:account_id]})
    end
    
    edit.before do
      add_crumb(object.to_s, edit_object_path)
    end
    
    update.before do
      @from_status = object.status
      @prev_status = object.prev_status
      add_crumb(object.to_s, edit_object_path)
    end
    
    update.after do
      process_status(@from_status, object.status, @prev_status)
    end
    
    show.before do
      add_crumb(object.to_s, object_path)
    end
    
    show.failure.wants.html { redirect_to url_for(dashboard_path) }

  private
  
    def collection
      @search = params[:search]
      @page = params[:page]
      @collection ||= Opportunity.search(@search).ordered.paginate(:page => @page)
    end
    
     def process_status(from, to, previous)
       result = nil    
       if from != to then
         begin
           case to.to_sym
             when :pending
               #flash.discard
               @object.revert_status(from)
               @object.reopen
               @object.set_status(to, from, true)
               flash[:notice] = 'The status was succesfully set to pending.'             
             when :at_client
               #flash.discard
               @object.revert_status(from)
               @object.send_client
               @object.set_status(to, from, true)
               flash[:notice] = 'The status was succesfully set to at client.'
             when :won
               #flash.discard
               @object.revert_status(from)
               @object.close_won
               @object.set_status(to, from, true)
               flash[:notice] = 'The status was succesfully set to won. A project was automatically created.'
             when :lost
               #flash.discard
               @object.revert_status(from)
               @object.close_lost
               @object.set_status(to, from, true)
               flash[:notice] = 'The status was succesfully set to lost.'
             when :closed
               #flash.discard
               @object.revert_status(from)
               @object.close
               @object.set_status(to, from, true)
               flash[:notice] = 'The status was succesfully set to close.'
             else
               @object.set_status(to, from, true)
           end
         rescue AASM::InvalidTransition
           status_text = @object.status_text_for(to)
           prev_status_text = @object.status_text_for(from)
           flash[:error] = "Error occured while changing status: cannot transition from #{prev_status_text} to #{status_text}. Reverted to old status: #{prev_status_text}." 
           @object.set_status(from, previous)
         end
         @object.save!
       end
       result     
    end
    
end
