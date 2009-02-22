class Pis::TimesheetsController < ApplicationController
  resource_controller
  before_filter :login_required, :is_valid_action?
  belongs_to :employee
  actions :all, :except => [:new, :destroy]

  protected
  
    def collection
      @page = params[:page]
      @collection ||= end_of_association_chain.ordered.paginate(:page => @page)
    end
  
    def object
      @object ||= (Timesheet.for_employee_and_year(parent_object.id, param).first || parent_object.timesheet)
    end
  
    def param
      @year = super
      @year = Time.now.year if @year.to_i < APP.setting('app.startyear').to_i
      @year
    end
  
    def is_valid_action?
      if !request.xhr? || !parent_object then
        error
        return false
      end
    end

end
