class Crm::AccountsController < ApplicationController
  resource_controller
  before_filter :login_required
  add_crumb("CRM Accounts") { |instance| instance.send :collection_path }

  # CUSTOMIZE
    [new_action, create].each{|action|
      action.before do
        add_crumb("New Account", new_object_path)
      end
    }
    
    [edit, update].each {|action|
      action.before do
        add_crumb(object.account.to_s, edit_object_path)
      end
    }
    
    show.before do
      add_crumb(object.account.to_s, object_path)
    end
    
    show.failure.wants.html { redirect_to url_for(dashboard_path) }
    
    def filter
      filter_collection
    end
  
  protected
  
    def object
      if ['edit', 'update', 'show', 'destroy'].include?(params[:action]) then
         @account ||= Account.find(param) unless param.nil?
         if @account then
           if (params[:action] == 'destroy') then
             @object ||= @account
           else
             @object ||= AccountCard.new(:account => @account, :accountcontactcard => @account.accountcontactcard)
           end
           @object
         else
            redirect_to(object_path)
         end
      else
        super
      end
    end
  
  private
    
    def model_name
      'AccountCard'
    end
    
    def collection
      @search = params[:search]
      @page = params[:page]
      @per_page = (!params[:per_page].blank?) ? params[:per_page] : Account.per_page
      @collection ||= Account.search(@search).ordered.paginate(:page => @page, :per_page => @per_page)
    end
    
end
