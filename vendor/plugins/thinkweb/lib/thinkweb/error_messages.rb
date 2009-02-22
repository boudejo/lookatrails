class ActiveRecord::Base
  def business_name
    self.class.name.titlecase
  end
end

module ActionView
  module Helpers
    module ActiveRecordHelper
      DEFAULT_PARTIAL = %{
        <div class="errorExplanation" id="errorExplanation">
          <h2><%= pluralize(errors.size, "error") %> <%= errors.size == 1 ? "needs" : "need" %> to be fixed.</h2>
          <ul>
            <% for error in errors -%>
              <li><%= error %></li>
            <% end -%>  
          </ul>
        </div>
      }
      
      alias_method :default_error_messages_for, :error_messages_for
      
      def error_messages_for(object_names = [], *params)
        options = params.extract_options!.symbolize_keys
        object_names = [object_names]
        object_names.flatten!
        custom_labels = options.delete(:labels) || {}
        app_errors = []
        
        object_names.each do |name| 
          object = instance_variable_get("@#{name}")
          if object
            object.errors.each do |key, value|
              custom_label = custom_labels.delete(key.to_sym) || nil
              
              if !custom_label.nil? then
                value = "^"+value
              end
             
              if object.kind_of? ActivePresenter::Base then
                parsed = key.underscore.split('_')
                object_name = parsed.shift.humanize
                prefix = parsed.join(' ').humanize
              else
                object_name = ''
                prefix = key.underscore.split('_').join(' ').humanize
              end
              
              if value.match(/^\^/)
                value = value[1..value.length]
                prefix = ''
              end
              
              if options[:strip_object_name] then
                object_name = ''
              elsif !(key.class == String && key == "base")
                object_name = object.business_name+' ' if !(object.kind_of? ActivePresenter::Base)
              end
              
              if options[:strip_field_name] then
                prefix = ''
              end
              
              if options[:clickable] && prefix then
                app_errors << "#{custom_label}#{object_name}<a href=\"##{key.downcase}\" class=\"error_for_link\">#{prefix}</a> #{value}"
              else
                app_errors << "#{custom_label}#{object_name}#{prefix} #{value}"
              end
            end
          end
        end
        
        unless app_errors.empty?
          partial_opts_defaults = {:id => '', :timeout => 0}
          partial_opts = partial_opts_defaults.merge(options)
          if options[:view_partial].nil?
            if File.exist?("#{RAILS_ROOT}/app/views/_application/results/_error_messages.html.erb")
              render :partial => "_application/results/error_messages", :locals => {:errors => app_errors, :options => partial_opts}
            else
              render :inline => DEFAULT_PARTIAL, :locals => {:errors => app_errors, :options => partial_opts}
            end
          else        
            render :partial => view_partial, :locals => {:errors => app_errors, :options => partial_opts}
          end
        else
          ""
        end
      end
      
      def tw_error_messages_for(*params)
        options = params.extract_options!.symbolize_keys
        if object = options.delete(:object)
          objects = [object].flatten
        else
          objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
        end
      end
      
    end
  end
end