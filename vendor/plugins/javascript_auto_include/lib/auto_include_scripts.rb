module AutoIncludeScripts
  
  module ControllerMethods
    module ClassMethods
     
      def auto_include_scripts(enabled = true)
        before_filter do |instance|
          instance.auto_include_scripts(enabled)
        end
      end
    end

    module InstanceMethods
      def auto_include_scripts(enabled)
        @_auto_include_scripts = enabled
      end
      
    end

    def self.included(receiver) # :nodoc:
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
  
  module ViewMethods
    def auto_include_scripts?
      @_auto_include_scripts
    end
  end
  
end