module RestfulAclHelper

  def creatable
    return true if admin_enabled
    
    klass.is_creatable_by(current_user)
  end
  alias_method :createable, :creatable
  
  
  def updatable(object)
    return true if admin_enabled
    
    object.is_updatable_by(current_user)
  end
  alias_method :updateable, :updatable
  
  
  def deletable(object)
    return true if admin_enabled
    
    object.is_deletable_by(current_user)
  end
  alias_method :deleteable, :deletable
  
  
  def readable(object = nil)
    return true if admin_enabled
    
    klass.is_readable_by(current_user, object)
  end  

  private
    
    def admin_enabled
      current_user.respond_to?("has_role?") && current_user.has_role?
    end
    
    def klass
      params[:controller].classify.constantize
    end

end