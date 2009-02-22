class UsersController < ApplicationController
  
  def index
    redirect_back_or_default('/')
  end
  
  def show
    redirect_back_or_default('/')
  end

  # RESTFULL AUTH:
    
  def new
    #@user = User.new
    @signup = Signup.new
  end
 
  def create
    logout_keeping_session!
    @signup = Signup.new(params[:signup])
    if @signup.save
      flash[:notice] = "Thanks for signing up!<br />You will receive an email in a few minutes with further instructions on how to activate your account."
      redirect_to '/login'
    else
      #flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_to '/login'
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_to '/login'
    end
  end

  # CUSTOM:
  
  def troubleshooting
  end
  
  def forgot_password
    if logged_in?
      redirect_back_or_default('/')
    end
    if request.put?
      @user = User.find_by_login_or_email(params[:email_or_login])
      @user = (!@user || @user.login == 'system') ? nil : @user
      if @user.nil?
        flash.now[:error] = 'No account was found by that login or email address.'
      else
        @user.forgot_password if @user.active?
      end
    end
  end
  
  def reset_password
    if logged_in?
      redirect_back_or_default('/')
    end
    begin
      @user = User.find_by_password_reset_code(params[:password_reset_code])
      @user = (!@user || @user.login == 'system') ? nil : @user
    rescue
      @user = nil
    end
    unless @user.nil? || !@user.active?
      @user.reset_password!
    end
  end
 
  def forgot_login
    if logged_in?
      redirect_back_or_default('/')
    end
    if request.put?
      begin
        @user = User.find_by_email(params[:email], :conditions => ['NOT state = ?', 'deleted'])
      rescue
        @user = nil
      end
      if params[:email].blank? then
        flash.now[:error] = 'Please provide an email address.'
      else
        if @user.nil?
          flash.now[:error] = 'No account was found with that email address.'
        else
          UserMailer.deliver_forgot_login(@user)
        end
      end
    end
  end
  
  def clueless
  end
 
  protected
  
  def find_user
    @user = User.find(params[:id])
  end

end
