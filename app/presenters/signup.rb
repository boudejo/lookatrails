class Signup < ActivePresenter::Base
  presents :user, :profile
  
  before_save :assign_profile_and_register
  
  def assign_profile_and_register
    @user.profile = @profile
    @user.register!
  end

end