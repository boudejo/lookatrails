class Pis::EmployeesController < ApplicationController
  resource_controller
  before_filter :login_required
  add_crumb("HR Employees") { |instance| instance.send :collection_path }
  
  # CUSTOMIZE
    [new_action, create].each{|action|
      action.before do
        add_crumb("New Employee", new_object_path)
      end
    }
  
    edit.before do
      add_crumb(object.employee.to_s, edit_object_path)
    end
    
    update.before do
      @from_status = object.employee.status
      @prev_status = object.employee.prev_status
      add_crumb(object.employee.to_s, edit_object_path)
    end
    
    update.after do
      process_status(@from_status, object.employee.status, @prev_status)
    end
  
    show.before do
      add_crumb(object.employee.to_s, object_path)
    end
    
    show.failure.wants.html { redirect_to url_for(dashboard_path) }

    def filter_consultants
      @search = params[:search]
      @page = params[:page]
      @per_page = 5
      data = Employee.filter_consultants(@search).ordered.paginate(:page => @page, :per_page => @per_page)
      filter_collection(data, 'pis/employees/filter_consultants')
    end

  protected

    def object
      if ['edit', 'update', 'show', 'destroy'].include?(params[:action]) then
         @employee ||= Employee.find(param) unless param.nil?
         if @employee then
           if (params[:action] == 'destroy') then
             @object ||= @employee
           else
             @object ||= @employee.presenter
           end
           @object
         else
            redirect_to(object_path)
         end
      else
        super
        if params[:action] == 'new' then
          @object.address = @object.employee.address
        end
        @object
      end
    end

    private

      def model_name
        'EmployeeProfile'
      end

      def collection
        @search = params[:search]
        @page = params[:page]
        @per_page = (!params[:per_page].blank?) ? params[:per_page] : Employee.per_page
        @collection ||= Employee.search(@search).ordered.paginate(:page => @page, :per_page => @per_page)
      end
     
      def update_nochanges?
        false
      end
      
      def process_status(from, to, previous)
        result = nil    
        if from != to then
          @object.employee.revert_status(from)
          begin
            case to.to_sym
              when :active
                #flash.discard
                @object.employee.activate
                flash[:notice] = 'The status was succesfully set to active.'
                object.employee.set_status(to, from, true)
              when :not_active
                #flash.discard
                @object.employee.inactive
                flash[:notice] = 'The status was succesfully set to not active.'
                object.employee.set_status(to, from, true)
              when :not_active
                #flash.discard
                @object.employee.no_longer_in_service
                flash[:notice] = 'The status was succesfully set to no longer in service.'
                object.employee.set_status(to, from, true)
              end
          rescue AASM::InvalidTransition
            status_text = @object.employee.status_text_for(to)
            prev_status_text = @object.employee.status_text_for(from)
            flash[:error] = "Error occured while changing status: cannot transition from #{prev_status_text} to #{status_text}. Reverted to old status: #{prev_status_text}." 
            @object.employee.set_status(from, previous)
          end
          @object.employee.save!
        end
        result     
      end
end