class Pis::CalendarEntriesController < ApplicationController
  resource_controller
  belongs_to :calendar
  before_filter :login_required, :is_valid_action?
  actions :all, :only => [:new, :create]

  # CUSTOMIZE
  
  new_action.before do
    @start = params[:start] || nil
    @end = params[:end] || nil
  end
  
  def create
    render :template => 'pis/calendar_entries/new' 
  end
=begin
  create do
    wants.html { 
      rebuild_object
      render :template => 'pis/calendar_entries/new' 
    }
    vfails.wants.html { 
      render :template => 'pis/calendar_entries/new' }
    failure.wants.html { 
      render :template => 'pis/calendar_entries/new' 
    }
  end
=end

  private
  
    def parent_object
      parent_model.for_year(parent_param).first
    end
  
    def is_valid_action?
      if !request.xhr? || !parent_object then
        error
        return false
      end
    end
  
end
