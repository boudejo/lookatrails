# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  add_crumb("Authentication") { |instance| instance.send :new_session_path }

  def index
    redirect_back_or_default('/')
  end
  
  def show
    redirect_back_or_default('/')
  end
  
  # render new.rhtml
  def new
    # Customized
      set_login_params
      clear_login_params
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = "Welcome #{self.current_user.login}, you logged in successfully !"
    else
      # Default behaviour (no redirect)
        note_failed_signin
        #@login       = params[:login]
        #@remember_me = params[:remember_me]
        #render :action => 'new'
      # Customized:
        store_login_params
        redirect_to('/login')
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been succesfully logged out."
    redirect_back_or_default('/login')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "The login/password combination you provided is incorrect or your account has not yet been activated."
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
