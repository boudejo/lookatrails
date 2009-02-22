class DocumentsController < ApplicationController
  resource_controller
  before_filter :login_required, :is_valid_action?
  add_crumb("Documents") { |instance| instance.send :collection_path }
  actions :all, :except => [:show, :edit]
  
  # CUSTOMIZE
    index.wants.html { render :template => 'documents/index' }
    new_action.wants.html { render :template => 'documents/new' }

    create do
      wants.html { redirect_to url_for([namespace, parent_object])+'/edit/?tab=files' }
      vfails.wants.html {
        clear_crumb(:all)
        params[:tab] = 'files'
        @editable = true
        if !parent_object.nil? then
          default_crumb
          subject = parent_object.class.to_s.downcase
          subject_plural = subject.pluralize
          add_crumb(namespace.to_s.upcase+' '+subject_plural.humanize, namespace(:url)+subject_plural)
          add_crumb(parent_object.to_s, url_for([:edit, namespace, parent_object]))
          if parent_object.respond_to?(:presenter) then
            instance_variable_set "@#{parent_type}", parent_object.presenter
          else
            instance_variable_set "@#{parent_type}", parent_object
          end
          render :template => namespace(:tpl)+subject_plural+'/edit'
        else
          redirect_to dasboard_path
        end
      }
    end
  
    destroy do
      wants.html { redirect_to url_for([namespace, parent_object])+'/edit/?tab=files' }
      failure.wants.html { redirect_to url_for([namespace, parent_object])+'/edit/?tab=files' }
    end
  
  private
    def is_valid_action?
      if !parent_object || (!request.xhr? && !(['create', 'destroy'].include?(params[:action]))) then
        if params[:action] == 'index' && parent_object && !request.xhr? then
          redirect_to url_for([namespace, parent_object])+'/edit/?tab=files'
        else
          redirect_to dashboard_path
        end
      end
    end
    
    def collection
      @page = params[:page]
      @per_page = (!params[:per_page].blank?) ? params[:per_page] : Document.per_page
      @collection ||= end_of_association_chain.ordered.paginate(:page => @page, :per_page => @per_page)
    end
  
end