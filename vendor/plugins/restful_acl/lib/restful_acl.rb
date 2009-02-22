module RestfulAcl
  
  def self.included(base)
    base.extend(ClassMethods)
    base.send :include, ClassMethods
  end
  
  module ClassMethods

    def has_permission?
      return true if current_user.respond_to?("has_role?") && current_user.has_role? # Admins rule.
      
      begin
        # Load the Model based on the controller name
        klass = (object) ? object.class : self.controller_name.classify.constantize

        # Load the object requested if the param[:id] exists
        resource = (object) ? object : (klass.find(params[:id]) unless params[:id].blank?)
        
        # Let's let the Model decide what is acceptable
        access_denied unless case params[:action] 
          when "index", "show"  then klass.is_readable_by(current_user, resource, params[:action])
          when "edit", "update" then resource.is_updatable_by(current_user)
          when "new", "create"  then klass.is_creatable_by(current_user)
          when "destroy"        then resource.is_deletable_by(current_user)
          else klass.is_readable_by(current_user, resource, params[:action])
        end
      
      rescue
        # Failsafe: If any funny business is going on, log and redirect
        error
      end
    end


    private

    def access_denied
      logger.info("[ACL] Access denied to %s at %s for %s" %
      [(logged_in? ? current_user.login : 'guest'), Time.now, request.request_uri])
  
      super
      #redirect_to denied_url
    end

    def error
      logger.info("[ACL] Error by %s at %s for %s" %
      [(logged_in? ? current_user.login : 'guest'), Time.now, request.request_uri])
  
      super
      #redirect_to error_url
    end
  
  end
end
