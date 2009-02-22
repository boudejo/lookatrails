class Pis::CalendarsController < ApplicationController
  resource_controller
  before_filter :login_required, :is_valid_action?
  actions :all, :except => [:new, :destroy]
  add_crumb("Calendars") { |instance| instance.send :collection_path }
  
  protected
    
    def collection
      @page = params[:page]
      @collection ||= end_of_association_chain.ordered.paginate(:page => @page)
    end
    
    def object
      @object ||= (Calendar.for_year(param).first || Calendar.for_year(Time.now.year).first)
    end
    
    def param
      @year = super
      @year = Time.now.year if @year.to_i < APP.setting('app.startyear').to_i
      @year
    end
    
    def is_valid_action?
      if !request.xhr? && !(['index'].include?(params[:action])) then
        error
        return false
      end
    end
  
end
