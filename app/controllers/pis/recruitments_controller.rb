class Pis::RecruitmentsController < ApplicationController
  resource_controller
  before_filter :login_required, :editable
  add_crumb("HR Recruitments") { |instance| instance.send :collection_path }
  
  # CUSTOMIZE
    [new_action, create].each{|action|
      action.before do
        add_crumb("New Recruitment", new_object_path)
      end
    }
  
    edit.before do
      add_crumb(object.recruitment.to_s, edit_object_path)
    end
    
    update.before do
      @from_status = object.recruitment.status
      @prev_status = object.recruitment.prev_status
      add_crumb(object.recruitment.to_s, edit_object_path)
    end
    
    update.after do
      process_status(@from_status, object.recruitment.status, @prev_status)
    end
  
    show.before do
      add_crumb(object.recruitment.to_s, object_path)
    end
    
    show.failure.wants.html { redirect_to url_for(dashboard_path) }

    FORECAST_FILTERS = %w{this_year previous_year this_month last_month}
    
    def forecast
=begin
      current_week = Date.today.strftime('%W')
      current_year = Date.today.strftime('%Y')
      startyear = APP.setting('app.startyear')
      @years = startyear
      if params[:macro].nil? or !FORECAST_FILTERS.include?(params[:macro])
        @recruitments = Recruitment.forecast_ordered
      else
        @recruitments = Recruitment.send("filter_#{params[:macro]}").forecast_ordered
      end
      @filters = FORECAST_FILTERS
      week = params[:week] || current_week
      year = params[:year] || current_year
      @week = (!week || week > 52 || week == 0) ? current_week : week
      @year = (!year || year > 2100 || year < 2008) ? current_year : year
=end
       @recruitments ||= Recruitment.forecast_ordered
    end

  protected
    
    def editable
      if params[:action] == 'edit' && object.recruitment.status_is_joboffer_signed? then
        redirect_to object_path
      end
    end

    def object
      if ['edit', 'update', 'show', 'destroy'].include?(params[:action]) then
         @recruitment ||= Recruitment.find(param) unless param.nil?
         if @recruitment then
           if (params[:action] == 'destroy') then
             @object ||= @recruitment
           else
             @object ||= @recruitment.presenter
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
        'RecruitmentProfile'
      end

      def collection
        @search = params[:search]
        @page = params[:page]
        @per_page = (!params[:per_page].blank?) ? params[:per_page] : Recruitment.per_page
        @collection ||= Recruitment.search(@search).ordered.paginate(:page => @page, :per_page => @per_page)
      end
     
      def update_nochanges?
        false
      end
      
      def process_status(from, to, previous)
        result = nil    
        if from != to then
          begin
            case to.to_sym
              when :joboffer_signed
                #flash.discard
                @object.recruitment.revert_status(from)
                begin # Handle if an exception occures (revert to old status !!)
                  @object.recruitment.signed
                  if !@object.recruitment.employee.nil? then
                    flash[:notice] = 'A employee (consultant) was succesfully created.'
                    @object.recruitment.set_status(to, from, true)
                  else
                    flash[:error] = 'There was a problem changing the status to signed. Please try again.'
                    @object.recruitment.set_status(from, previous)
                  end
                rescue Exception => exc
                  flash[:error] = "An error occured while changing status to joboffer signed. Please report this error to your support staff: <br/><strong>#{exc.message}</strong>."
                  @object.recruitment.set_status(from, previous)
                end
              when :rejected
                #flash.discard
                @object.recruitment.revert_status(from)
                @object.recruitment.reject
                @object.recruitment.set_status(to, from, true)
                flash[:notice] = 'The status was succesfully set to rejected.'
              else
                @object.recruitment.set_status(to, from, true)
            end
          rescue AASM::InvalidTransition
            status_text = @object.recruitment.status_text_for(to)
            prev_status_text = @object.recruitment.status_text_for(from)
            flash[:error] = "Error occured while changing status: cannot transition from #{prev_status_text} to #{status_text}. Reverted to old status: #{prev_status_text}." 
            @object.recruitment.set_status(from, previous)
          end
          @object.recruitment.save!
        end
        result     
     end
    
end
