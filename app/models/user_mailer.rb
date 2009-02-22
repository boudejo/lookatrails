class UserMailer < ActionMailer::Base
  
  # RESTFULL AUTH:
  
  def signup_notification(user)
    app_setup_mail
    setup_email(user)
    @subject += "Please activate your new #{APP.setting('app.name')} account"
    debug_mail if APP.setting('debug.mail.enabled')
  end
  
  def activation(user)
    app_setup_mail
    setup_email(user)
    @subject += "Your #{APP.setting('app.name')} account has been activated!"
    debug_mail if APP.setting('debug.mail.enabled')
  end
  
  # CUSTOM:
  
  def forgot_password(user)
    app_setup_mail
    setup_email(user)
    @subject += "Forgotten password instructions"
    debug_mail if APP.setting('debug.mail.enabled')
  end
  
  def reset_password(user)
    app_setup_mail
    setup_email(user)
    @subject += "Your password has been reset"
    debug_mail if APP.setting('debug.mail.enabled')
  end
  
  def forgot_login(user)
    app_setup_mail
    setup_email(user)
    @subject += "Forgotten account login"
    debug_mail if APP.setting('debug.mail.enabled')
  end
  
  def update_password(user, new_password)
    app_setup_mail
    setup_email(user)
    @subject += "Your password has been changed"
    @body[:new_password] = new_password
    debug_mail if APP.setting('debug.mail.enabled')
  end
  
  def update_email(user)
    app_setup_mail
    setup_email(user)
    @subject += "Your email address has been changed"
    debug_mail if APP.setting('debug.mail.enabled')    
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.to_s(:mail)}"
      @body[:user] = user
    end
end
