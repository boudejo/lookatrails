class Admin::UsersController < ApplicationController
  resource_controller
  before_filter :login_required
  layout 'admin'
  add_crumb("User Management") { |instance| instance.send :collection_path }
  
  require_role [:admin]
  
  show.failure.wants.html { redirect_to url_for(admin_dashboard_path) }
  
   # def suspend
   #    @user.suspend! 
   #    redirect_to users_path
   #  end
   # 
   #  def unsuspend
   #    @user.unsuspend! 
   #    redirect_to users_path
   #  end
   # 
   #  def destroy
   #    @user.delete!
   #    redirect_to users_path
   #  end
   # 
   #  def purge
   #    @user.destroy
   #    redirect_to users_path
   #  end
  
  protected
  
  def find_user
    @user = User.find(params[:id])
  end
  
  private
    def collection
      @search = params[:search]
      @page = params[:page]
      @filter_role = "support"
      @collection ||= end_of_association_chain.search(@search).with(:roles).for_role(@filter_role).ordered.paginate(:page => @page)
    end
    
    
end
