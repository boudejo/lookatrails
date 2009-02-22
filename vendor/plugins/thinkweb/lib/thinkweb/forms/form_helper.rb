module ActionView
  module Helpers
    module FormHelper
  
      # CUSTOM FORM BUILDER
      
      %w(form_for remote_form_for fields_for).each do |helper|
        src = <<-end_src
          def tpl_#{helper}(object_name, *args, &proc)
            options = parse_tpl_form_options!(object_name, args.extract_options!)
            options.merge! :builder => TW::Forms::TWFormBuilder
            #{helper}(object_name, *(args << options), &proc)
          end
        end_src
    
        class_eval src, __FILE__, __LINE__
      end
  
      # ENUM FORM SUPPORT
      
      # Helper to create a select drop down list for enumerated values
      def enum_select(object_name, method, options = {})
        InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_enum_select_tag(parse_enum_options!(options))
      end
      
      # Helper to create a select drop down list for enumerated values
      def enum_select2(object_name, method, options = {})
        InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_enum_select2_tag(parse_enum_options!(options))
      end

      # Creates a set of radio buttons for all the enumerated values.
      def enum_radio_group(object_name, method, options = {})
        InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_enum_radio_tag(parse_enum_options!(options))        
      end
      
      def read_only_field(object_name, method, options = {})
        InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_read_only(options)
      end

      private
    
        def parse_tpl_form_options!(object_name, options)
          if options[:html].nil? then
            options[:html] = { :class => "form" }
          else
            options[:html][:class] = (options[:html][:class].nil?) ? "form" : "form #{options[:html][:class]}"
          end
          defaults = {:partial => 'DEFAULT', :autofocus => true}
          options[:defaults] = defaults.merge!(options.delete(:opts) || {})
          options
        end
        
        def parse_enum_options!(options)
          html = options.delete(:html)
          if html.nil? then
            options[:class] = "enum"
          else
            options[:class] = (html[:class].nil?) ? "enum" : "enum #{html[:class]}"
          end
          options[:text] = options[:text] || []
          options
        end
    end
    
    class InstanceTag #:nodoc:

      # Create a select tag and one option for each of the
      # enumeration values.
      def to_enum_select2_tag(options = {})
        add_default_name_and_id(options)
        val = ''
        if !object.nil? then
          val = value(object)
        end
        val = options.delete(:value) || val
        
        if object.respond_to?(@method_name+'_select_values') then
          values = object.send(@method_name+'_select_values')
        else
          values = options.delete(:values) || []
        end
        
        if object.respond_to?(@method_name+'_select_labels') then
          labels = object.send(@method_name+'_select_labels')
        else
          labels = options.delete(:labels) || []
        end
        
        puts values.inspect
        puts labels.inspect

        option_values = []
        values.each_with_index do |value, index|
          option_value = (!options[:store_as].nil? && options[:store_as] == :int) ? index : value.to_s
          if !labels.nil? && !labels[index].nil? then
            option_values.push([labels[index].to_s.humanize, option_value])
          else
            option_values.push([value.to_s.humanize, option_value])
          end
        end
        
        select_tag(nil, options_for_select(option_values, val), options)
      end
      
      # Create a select tag and one option for each of the
      # enumeration values.
      def to_enum_select_tag(options = {})
        add_default_name_and_id(options)
        val = ''
        if !object.nil? then
          val = value(object)
        end
        val = options.delete(:value) || val
        
        if !val.blank? then
          val = (val.class == String) ? val.to_sym : val.to_i
        end
        
        if options[:values] then
          values = options.delete(:values)
          default_values_text = options.delete(:default_text) || values
        else
          values = enum_values
          dependencies = enum_dependencies(val)
          values_text = options.delete(:text)
          default_values_text = enum_text_values

          new_values = []
          values.each do |k, v|
            if (dependencies.nil? || dependencies.include?(k) || k == val) then
              default_text = default_values_text.slice!(0)
              text = (values_text.slice(0)) ? values_text.slice!(0) : default_text
              if v.class == String then
                # text enum
                new_values.push([text.to_s.humanize, k])
              elsif v.class == Fixnum then
                # int enum
                new_values.push([text.to_s.humanize, v])
              end
            else
              default_values_text.slice!(0)
              values_text.slice!(0)
            end
          end
          values = new_values
=begin        
          values = values.map {|k, v|
            if (dependencies.nil? || dependencies.include?(k)) then
              default_text = default_values_text.slice!(0)
              text = (values_text.slice(0)) ? values_text.slice!(0) : default_text
              if v.class == String then
                # text enum
                k = [text.to_s.humanize, k]
              elsif v.class == Fixnum then
                # int enum
                k = [text.to_s.humanize, v]
              end
            else
              values.delete(k)
            end
          }
        end
=end          
        end
        
        select_tag(nil, options_for_select(values, val), options)
      end

      # Creates a set of radio buttons and labels.
      def to_enum_radio_tag(options = {})
        add_default_name_and_id(options)
        val = ''
        if !object.nil? then
          val = value(object)
        end
        val = options.delete(:value) || val
        
        if options[:values] then
          values = options.delete(:values)
          default_values_text = options.delete(:default_text) || values
        else
          values = enum_values
          values_text = options.delete(:text)
          default_values_text = enum_text_values
        end
        
        if !val.blank? then
          val = (val.class == String) ? val.to_sym : val.to_i
        end
        
        tag_text = ''
        values = values.map {|k, v|
          default_text = default_values_text.slice!(0)
          text = (values_text.slice(0)) ? values_text.slice!(0) : default_text
          opts = {}
          opts['checked'] = 'checked' if v and v == val
          #opts['id']      = "#{opts['id']}_#{enum}"
          tag_text << '<div id="'+v+'_container">'
          tag_text << "<label>"
          tag_text << "#{text.to_s.humanize}: " if options[:reverse_label] == false
          tag_text << to_radio_button_tag(v, opts)
          tag_text << " #{text.to_s.humanize}" if options[:reverse_label] == true
          tag_text << "</label>"
          tag_text << '</div>'
        }
        
        return tag_text
      end

      # Read only value of field
      def to_read_only(options = {})
        val = ''
        if !object.nil? then
          val = value(object)
        end
        val = options.delete(:value) || val
        if options[:textile] then
            RedCloth.new(val).to_html unless !val
        else
          if !object.nil? then
            case options[:type]
              when 'enum_select'
                enum_value(val)
              else
                val
            end
          else
            val
          end
        end
      end

      # Gets the list of values for the column.
      def enum_values
        object.send(@method_name+"_sorted")
      end
      
      def enum_dependencies(value)
        object.send(@method_name+"_dependencies", value)
      end
      
      def enum_text_values
        object.send(@method_name+"_text_values")
      end
      
      def enum_value(value)
        object.send(@method_name+'_text_for', value)
      end
      
    end
    
  end
end