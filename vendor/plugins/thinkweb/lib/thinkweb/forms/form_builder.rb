module TW::Forms
  
  class TWFormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper
    
    attr_accessor :section_options, :readonly
    
    def initialize(object_name, object, template, options, proc)
      super(object_name, object, template, options, proc)
      @section_options = {}
      @scripts = {}
      @styles = {}
      @readonly = options.delete(:readonly) || false
    end
    
    helpers = field_helpers +
              %w{date_select datetime_select time_select} +
              %w{collection_select select country_select time_zone_select}
              
    helpers.each do |selector|
      src = <<-END_SRC
        def #{selector}(field, options = {})
          field_opts = extract_tw_options(field.to_s, options)
          field_content = (field_opts[:readonly]) ? read_only_field(field, '#{selector}', field_opts) : super
          generic_field(field.to_s, field_content, '#{selector}', field_opts)
        end
        END_SRC
        class_eval src, __FILE__, __LINE__
    end
     
    # LAYOUT HELPERS
    
    def fieldset(legend=nil, *args, &block)
     options = args.extract_options!
     html = opts_to_html_attributes(extract_default_html!(options[:html] || {}), {:class => 'form_fieldset'})
     @section_options = extract_section_options! options
     @section_options[:type] = 'fieldset'
     concat("<fieldset#{html}>\n#{"<legend>#{legend}</legend>" if legend}\n<div class=\"form_container\">",block.binding)
     yield
     concat("\n</div>\n</fieldset>",block.binding)
     @section_options = {}
    end
     
    def table(*args, &block)
      options = args.extract_options!
      html = opts_to_html_attributes(extract_default_html!(options[:html] || {}), {:class => 'form_table'})
      @section_options = extract_section_options! options
      @section_options[:type] = 'table'
      @section_options[:partial] = 'TABLE_ROW'
      concat("<table#{html}>",block.binding)
      yield
      concat("</table>",block.binding)
      @section_options = {}
    end
    
    def table_row(*args, &block)
      options = args.extract_options!
      label = options.delete(:label) || nil
      column = column_after = ''
      html = opts_to_html_attributes(extract_default_html!(options[:html] || {}), {:class => 'table_row'})
      @section_options = extract_section_options! options
      if label.nil? then
        @section_options[:type] = 'table_row'
        @section_options[:partial] = 'TABLE_COLUMN'
      else
        @section_options[:type] = nil
        @section_options[:partial] = 'LABEL_FIELD'
      end
      if !label.nil? then
        column = '<td class="label">'+label+':</td><td class="element multiple">'
        column_after = '</td>'
      end
      concat("<tr#{html}>#{column}",block.binding)
      yield
      concat("#{column_after}</tr>",block.binding)
      @section_options = {}
    end

    def list(type='ol', *args, &block)
      options = args.extract_options!
      html = opts_to_html_attributes(extract_default_html!(options[:html] || {}), {:class => 'form_list'})
      @section_options = extract_section_options! options
      @section_options[:type] = 'list'
      type = (['ol', 'ul'].include? type) ? type : 'ol'
      @template.content_tag type.to_sym, "", html, &block
      @section_options = {}
    end
    
    # FORM HELPERS

    def filterlist(field, *args)
      @scripts[:filterlist] = 'lib/jquery/plugins/app/jquery.filterlist.js' if !@scripts.has_key?(:filterlist)
      options = args.extract_options!
      field_opts = extract_tw_options(field.to_s, options)
      obj_attr = options.delete(:attr) || 'name'
      obj_attr_cache = options.delete(:attr_cache) || false
      subject = field_opts.delete(:subject)
      if !@object.respond_to?("#{subject}") then
        subject = field.to_s
      end
      subject_title = options.delete(:title) || "No #{subject} selected"
      fieldid = subject+'_id'
      fieldvalue = subject+'_'+obj_attr
      filterlist_html = subject_title
      if @object.respond_to?("#{subject}") then
        # LABEL
        if (field_opts[:label].nil?) then
          field_opts[:label] = nil
        else
          fieldlabel = {}
          fieldlabel[:text] = (field_opts[:label].class == Hash) ? field_opts[:label][:text] : field_opts[:label]
          fieldlabel[:for]  = @object_name.to_s+'_'+fieldid
          field_opts[:label] = fieldlabel
        end
        # TITLE & VALUE
        subject_obj = @object.send("#{subject}")
        if @object.new_record? then
          if !subject_obj.nil? then
            subject_value = (subject_obj.respond_to?(:id)) ? subject_obj.send(:id) : "Undefined attribute id for #{subject_obj.class.to_s}"
            subject_title = (subject_obj.respond_to?(obj_attr.to_sym)) ? subject_obj.send(obj_attr.to_sym) : "Undefined attribute #{obj_attr.to_s} for #{subject_obj.class.to_s}"
          else
            subject_value = ''
            subject_title = 'No account selected'
          end
        else
          if field_opts[:readonly] then
            if @object.respond_to?("#{fieldvalue}") then
              subject_title = @object.send(fieldvalue.to_sym)
            else
              subject_title = "Undefined attribute #{fieldvalue.to_s} for #{subject_obj.class.to_s}"
            end
          else
            subject_value = (subject_obj) ? subject_obj.send(:id) : '' if !field_opts[:readonly]
            if obj_attr_cache == true then
              if @object.respond_to?("#{fieldvalue}") then
                subject_title = @object.send(fieldvalue.to_sym)
              else
                subject_title = "Undefined attribute #{fieldvalue.to_s} for #{subject_obj.class.to_s}"
              end
            else
              subject_title = subject_obj.send(obj_attr.to_sym)
            end 
          end
        end
        # GENERATE TAG
        section_opts = @section_options
        @section_options = {}
        if field_opts[:readonly] then
          filterlist_html = read_only_field(fieldid.to_sym, 'filterlist', {:value => subject_title})
        else
          filterlist_html = hidden_field(fieldid.to_sym, :title => subject_title, :value => subject_value)
        end
        @section_options = section_opts
      else
        filterlist_html = "Undefined object #{field.to_s} for #{@object.class.to_s}"
      end
      generic_field(field.to_s, filterlist_html, 'filterlist', field_opts)
    end
    
    def date_field(field, options = {})
      @scripts[:date_field] = 'lib/jquery/ui/datepicker.js' if !@scripts.has_key?(:date_field)
      @styles[:date_field]  = 'jquery-ui-theme.css' if !@styles.has_key?(:date_field)
      field_opts = extract_tw_options(field.to_s, options)
      value = (@object.respond_to?(field.to_s)) ? @object.send(field.to_s) : ''
      value = (value.class == Date) ? value.strftime(Date::DATE_FORMATS[:default]) : ''
      field_opts[:value] = value
      if (field_opts[:readonly]) then
        date_field_html = read_only_field(field.to_s, 'date_field', field_opts)
      else
        date_field_html = @template.text_field(@object_name, field, options.merge({:value => field_opts[:value]}))
      end
      generic_field(field.to_s, date_field_html, 'date_field', field_opts)
    end
    
    def enum2_select(field, options = {})
      field_opts = extract_tw_options(field.to_s, options)
      if (field_opts[:readonly]) then
        enum_select_html = read_only_field(field.to_s, 'enum_select', field_opts)
      else
        enum_select_html = @template.enum_select2(@object_name, field, options.merge({:value => field_opts[:value]}))
      end
      generic_field(field.to_s, enum_select_html, 'enum_select', field_opts)
    end
    
    def enum_select(field, options = {})
      field_opts = extract_tw_options(field.to_s, options)
      if (field_opts[:readonly]) then
        enum_select_html = read_only_field(field.to_s, 'enum_select', field_opts)
      else
        enum_select_html = @template.enum_select(@object_name, field, options.merge({:value => field_opts[:value]}))
      end
      generic_field(field.to_s, enum_select_html, 'enum_select', field_opts)
    end
    
    def enum_radio_group(field, options = {})
      field_opts = extract_tw_options(field.to_s, options)
      if (field_opts[:readonly]) then
        enum_radio_group_html = read_only_field(field.to_s, 'enum_radio_group', field_opts)
      else
        enum_radio_group_html = @template.enum_radio_group(@object_name, field, options.merge({:value => field_opts[:value], :reverse_label => field_opts[:reverse_label]}))
      end
      generic_field(field.to_s, enum_radio_group_html, 'enum_radio_group', field_opts)
      
    end
    
    def country_select(field, options = {})
      field_opts = extract_tw_options(field, options)
      if (field_opts[:readonly]) then
        country_select_html = read_only_field(field.to_s, 'country_select', options)
      else
        country_select_html = @template.country_select(@object_name, field, options, {}, field_opts.delete(:html))
      end
      generic_field(field.to_s, country_select_html, 'country_select', field_opts)
    end
    
    # def enum_radio_group(method, *args)
    # end  
    
    # def enum_checkbox_group(method, *args)
    # end
    
    def submit(*args)
      super
    end

    def hidden_field(*args)
      super
    end
   
    protected
    
      def read_only_field(fieldname, helper, options = {})
        if options[:texttile] || helper == 'text_area' then
          partial = TW::Partials::Form::READONLY_TEXTAREA
        else
          partial = TW::Partials::Form::READONLY_FIELD
        end
        default = options.delete(:default) || '-'
        if options[:value] then
          val = options.delete(:value)
        else
          val = (object.respond_to?(fieldname)) ? object.send(fieldname).to_s : ''
          if options[:texttile] || helper == 'text_area' then
              val = RedCloth.new(val).to_html if !val.blank?
          else
              case helper
                when 'enum_select'
                  val = @template.read_only_field(@object_name, fieldname, options.merge({:type => helper}))
                when 'enum_radio_group'
                  val = @template.read_only_field(@object_name, fieldname, options.merge({:type => helper}))
              end
          end
        end
        hidden = options.delete(:hidden_read) || false
        if hidden == true then
          val = val + hidden_field(fieldname, extract_default_html!(options))
        end
        @template.render :inline => partial, :locals => {:value => ((val.blank?) ? default : val), :container => '', :style => ''}
      end
    
      def generic_field(fieldname, field, helper, options = {})
        if options[:display] != :hide then
          data = {}
      
          data[:required]           = options[:required] ? @template.content_tag('span', '*', :class => 'required_field') : ''
          data[:help]               = options[:help] ? @template.content_tag('span', " #{options[:help]}", :class => 'help_field') : ''
          data[:note]               = options[:note] ? @template.content_tag('em', " #{options[:note]}", :class => 'note_field') : ''
          data[:append_field]       = options[:append_field] ? ' '+options[:append_field] : ''
          data[:prepend_field]      = options[:prepend_field] ? options[:prepend_field]+' ' : ''
          data[:append_label]       = options[:append_label] ? ' '+options[:append_label] : ''
          data[:prepend_label]      = options[:prepend_label] ? options[:prepend_label]+' ' : ''
          data[:append_label_text]  = options[:append_label_text] ? options[:append_label_text] : ''
          data[:prepend_label_text] = options[:prepend_label_text] ? options[:prepend_label_text] : ''
      
          label = extract_label_options! options

          if (label && !label[:text].blank?) then
            label[:text] ||= "#{@object_name}_#{fieldname}".humanize
            label[:for]  ||= "#{@object_name}_#{fieldname}".gsub(/[^a-z0-9_-]+/, '_').gsub(/^_+|_+$/, '')
            if label[:text] then
              label[:text] = data[:prepend_label_text]+label[:text]+data[:append_label_text]
            end
            data[:label] = label_tag label
          else
            data[:append_label] = ''
            data[:append_label_text] = ''
            data[:label] = ''
          end
      
          if options[:readonly] then
            data[:field] = field.to_s
          else
            data[:field] = field + set_focus(fieldname, options)
          end
        
          data[:container] = (!options[:container].blank?) ? " id=\"#{options[:container]}\"" : ''
          data[:style] = (options[:display] == :hidden) ? " style=\"display: none;\"" : ''
      
          partial = get_partial(options[:partial], check_or_radio?(helper))
      
          if !@section_options[:type].nil?
              partial = case @section_options[:type]
              when 'list' then 
                (@section_options[:partial] != 'LIST_ITEM') ? (@template.content_tag :li, partial) : partial
              else partial
              end
          end
      
          # SCRIPTS
          if @scripts.has_key?(helper.to_sym) && @scripts[helper.to_sym] != true then
            @template.javascript(@scripts[helper.to_sym], true)
            @scripts[helper.to_sym] = true
          end
      
          # STYLES
          if @styles.has_key?(helper.to_sym) && @styles[helper.to_sym] != true then
            @template.stylesheet(@styles[helper.to_sym], 'screen')
            @styles[helper.to_sym] = true
          end
        
          @template.render :inline => partial, :locals => data
        end
      end

      def apply_value_format(value, format_opts)
        if format_opts.class == Hash then
          format = format_opts.delete(:format) || nil
          format_method = format_opts.delete(:method) || nil
          format_params = format_opts.delete(:params) || nil
        else 
          format = format_opts
        end
        case format
          when :float
            sprintf("%.2f", value.to_f) 
          else
            value
        end
      end

      def extract_tw_options field, options
        field_opts = {}
        label = options.delete(:label) || field.to_s.humanize
        field_opts[:label] = (label == :none) ? nil : label
        field_opts[:required] = options.delete(:required) || false
        field_opts[:textile] = options.delete(:textile) || false
        field_opts[:readonly] = options.delete(:readonly) || @readonly
        field_opts[:hidden_read] = options.delete(:hidden_read) || false
        field_opts[:display] = options.delete(:display) || :show
        field_opts[:container] = options.delete(:container) || ''
        field_opts[:reverse_label] = options.delete(:reverse_label) || false
        field_opts[:value] = options.delete(:value) || nil
        field_opts[:help] = options.delete(:help) || false
        field_opts[:note] = options.delete(:note) || false
        field_opts[:subject] = options.delete(:subject) || @object_name
        field_opts[:partial] = options.delete(:partial) || nil
        field_opts[:append_field] = options.delete(:append_field) || ''
        field_opts[:prepend_field] = options.delete(:prepend_field) || ''
        field_opts[:append_label] = options.delete(:append_label) || ''
        field_opts[:prepend_label] = options.delete(:prepend_label) || ''
        field_opts[:append_label_text] = options.delete(:append_label_text) || ':'
        field_opts[:prepend_label_text] = options.delete(:prepend_label_text) || ''
        field_opts[:html] = options.delete(:html) || {}
        field_opts
      end
      
      def extract_section_options! options
          partial = get_partial(options.delete(:partial), false, false) || get_partial(nil, false, false)
          {:partial => partial}
      end
      
      def extract_label_options!(args) #:nodoc:
        label = args.delete :label
        label = case label
        when Hash     then label
        when String   then { :text => label }
        when nil,true then {}
        end
        label
      end
      
      def extract_label_html!(label) #:nodoc:
        [:id, :class, :for, :title, :style].inject({}) { |html,k| html.merge k => label.delete(k) }
      end
      
      def extract_default_html!(opts)
         [:id, :class, :title, :style].inject({}) { |html,k| html.merge k => opts.delete(k) }
      end
      
      def opts_to_html_attributes(opts, defaults={})
        html, default = ''
        opts.each do |key,val|
          default = defaults[key]+(!val.blank? ? ' ' : '') if defaults.has_key?(key)
          html << " #{key}=\"#{default}#{val}\"" if !val.blank? || !default.blank?
          default = ''
        end
        html
      end
      
      def check_or_radio?(helper) #:nodoc:
        [:check_box, :radio_button].include? helper.to_sym
      end
      
      def get_partial(partial=nil,reverse=false,parsed=true)
        if partial.nil? || partial.blank? then
          if !@section_options[:partial].nil? then
            partial = @section_options[:partial]
          else
            if !@options[:defaults][:partial].nil? then
              partial = @options[:defaults][:partial]
            end
          end
        end
       
        if reverse then
          partial = (partial[-6..6] == '_REVERSE') ? partial : partial.to_s+'_REVERSE'
        end
        
        if parsed then
          (partial?(partial)) ? TW::Partials::Form::const_get(partial.to_sym) : default_partial(reverse)
        else
          (partial?(partial)) ? partial.to_s : default_partial(reverse, false)
        end
      end
      
      def default_partial(reverse=false, parsed=true)
        if parsed then
           (reverse) ? TW::Partials::Form::DEFAULT_REVERSE : TW::Partials::Form::DEFAULT
        else
          (reverse) ? 'DEFAULT_REVERSE' : 'DEFAULT'
        end
      end
      
      def partial?(partial)
        !!(!partial.nil? && TW::Partials::Form.const_defined?(partial.to_sym))
      end
      
      # Custom Form Helpers
      private
      
        def label_tag label, template = self
          if (label[:block]) then
            if label[:style] then
              label[:style] << ' display: block;'
            else
              label[:style] = 'display: block;'
            end
          end
          if (label[:inline]) then
            if label[:style] then
              label[:style] << ' display: inline;'
            else
              label[:style] = 'display: inline;'
            end
          end
     
          label[:title] = label[:text] if !label[:title]
          label_html = extract_label_html! label
          template.content_tag 'label', label[:text] , label_html
        end
    
        def set_focus(fieldname, options)
          return '' if is_disabled?(options) || is_readonly?(options)
          if @options[:defaults][:autofocus] && !@template.instance_variable_defined?('@focus_was_set')
            @template.instance_variable_set('@focus_was_set', @template.javascript_tag("document.getElementById('#{tag_id(fieldname)}').focus()"))
          else
            ''
          end
        end
        
        def is_disabled? options
          options.has_key?(:disabled) && options[:disabled] != false  
        end

        def is_readonly? options
          options.has_key?(:readonly) && options[:readonly] != false  
        end

        def tag_id field
          "#{sanitized_object_name}_#{sanitized_field_name field}"
        end

        def sanitized_object_name
          @sanitized_object_name ||= @object_name.to_s.gsub(/[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
        end

        def sanitized_field_name field
          field.to_s.sub(/\?$/,"")
        end
    
    end

end