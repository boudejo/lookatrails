class ProfilesController < ApplicationController
  resource_controller
  belongs_to :user
  actions :all, :except => [:destroy, :new, :create, :edit]
  
  before_filter :login_required
  before_filter :find_user_profile
  before_filter :check_owner_access, :only => [:update, :update_password, :update_password]
  
  update do
    flash_now "Your profile was succesfully updated."
    wants.html {render :action => "my_profile"}
    nochanges.flash "Your profile was not changed, nothing to update."
    nochanges.wants.html {redirect_to my_profile_path}
    fails.flash_now "Your profile was not correctly saved, an error occured."
    failure.wants.html {render :action => "my_profile"}
    vfails.wants.html {render :action => "my_profile"}
  end

  show.failure.wants.html { redirect_to url_for(dashboard_path) }
  
  update.before do
     add_crumb("My profile", my_profile_path)
  end

  def my_profile
    add_crumb("My profile", my_profile_path)
    @object = @profile
  end
  
  def edit_password
  end
  
  def update_password
    if current_user == @user
      current_password, new_password, new_password_confirmation = params[:current_password], params[:new_password], params[:new_password_confirmation]
      if @user.encrypt(current_password) == @user.crypted_password
        if new_password == new_password_confirmation
          if new_password.blank? || new_password_confirmation.blank?
            flash[:error] = "You cannot set a blank password."
            redirect_to my_profile_path
          else
            if @user.update_attributes(:password => new_password, :password_confirmation => new_password_confirmation) then
              flash[:notice] = "Your password has been updated. A confirmation email was send to your email address."
              UserMailer.deliver_update_password(@user, new_password)
              redirect_to my_profile_path
            else
              add_crumb("My profile", my_profile_path)
              @object = @user.profile
              render :action => "my_profile"
            end
          end
        else
          flash[:error] = "Your new password and it's confirmation don't match."
          redirect_to my_profile_path
        end
      else
        flash[:error] = "Your current password is not correct. Your password has not been updated."
        redirect_to my_profile_path
      end
    else
      flash[:error] = "You cannot update another user's password!"
      redirect_to my_profile_path
    end
  end
  
  def edit_email
    @current_email = current_user.email
  end
  
  def update_email
    if current_user == @user
      @user.attributes = params
      if (@user.changed? == false) then
        flash[:notice] = "Your email address was not changed, nothing to update."
        redirect_to my_profile_path
      else
        if @user.update_attributes(:email => params[:email]) then
          flash[:notice] = "Your email address has been succesfully updated. A confirmation email was send to your newly registered email address."
          UserMailer.deliver_update_email(@user)
          redirect_to my_profile_path
        else
          add_crumb("My profile", my_profile_path)
          @object = @user.profile
          render :action => "my_profile"
        end
      end
    else
      flash[:error] = "You cannot update another user's email address!"
      redirect_to my_profile_path
    end
  end

  private
    def find_user_profile
      begin
        @user = (params[:action] == 'my_profile') ? current_user : User.find_by_id(params[:id])
      rescue
        @user = nil
      end
      @profile = @user.nil? ? nil : @user.profile
    end
    
    def check_owner_access
      redirect_to profile_path(params[:id]) if logged_in? && current_user != @user
    end
    
    def object
      @object ||= @profile
    end
    
end
