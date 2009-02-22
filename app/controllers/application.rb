# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  auto_include_scripts
  auto_include_styles
  #activate_js_erb_auto_include
  sliding_session_timeout APP.setting('session.timeout'), :on_expire if APP.setting('session.timeout') > 0

  include AuthenticatedSystem
  include RoleRequirementSystem
  include Userstamp
  
  layout :determine_layout
  before_filter :load_section_config, :default_crumb, :meta_defaults
  helper :all # include all helpers, all the time
  
  # Rescues
  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalid_token
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '1bd47a8a578568813b9423fd324bc5e3'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  private
  
    def determine_layout
      if request.xhr? then
        nil
      else
        "application"
=begin
        if logged_in? then
          "application"
        else
          "public"
        end
=end
      end
    end
  
  public 
  
    def access_denied
      uri = request.request_uri;
      if uri == '/' then
    	  respond_to do |format|
      	format.html do
        		store_location
        		redirect_to new_session_path
      	end
      	format.any(:json, :xml) do
        		request_http_basic_authentication 'Web Password'
      	end
    	end
      else
      	render :template => "_application/views/access_denied", :layout => false
      end
    end
    
    def error
      render :template => "_application/views/error", :layout => false
    end
  
    def changelog
      if logged_in?
        add_crumb "Changelog"
        # Get contents of changelog file for display
        @changelog = ''
        begin
          file = File.new(RAILS_ROOT+"/app/changelog.txt", "r")
          while (line = file.gets)
            @changelog << "#{line}"
          end
          file.close
        rescue => err
          @changelog = "Exception: #{err}"
        end
        render :template => "_application/views/changelog"
      else
        redirect_back_or_default('/')
      end
    end
end
