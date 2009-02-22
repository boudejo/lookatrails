module AutoIncludeStyles
  
  module ControllerMethods
    module ClassMethods
     
      def auto_include_styles(enabled = true)
        before_filter do |instance|
          instance.auto_include_styles(enabled)
        end
      end
    end

    module InstanceMethods
      def auto_include_styles(enabled)
        @_auto_include_styles = enabled
      end
      
    end

    def self.included(receiver) # :nodoc:
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
  
  module ViewMethods
    def auto_include_styles?
      @_auto_include_styles
    end
  end
  
end