module TW
  
  module ViewHelpers
   
    def xhr?
      request.xhr?
    end
    
    def object_identity_field(object)
      hidden_field_tag object.class.to_s.downcase+'_id', object.id
    end
    
    # Print related
    def default_print_styles
      styles = []
      if printable? then
        styles << 'print' if File.exists?(File.join(ActionView::Helpers::AssetTagHelper::STYLESHEETS_DIR, 'print.css'))
      end
      styles
    end
    
    def default_print_styles?
      !!default_print_styles.length
    end
    
    def printmode
      if (@printmode == nil || @printmode) then
        return 'portrait'
      end
      return 'landscape'
    end
    
    def printable?
        (@printable == nil || @printable === true) ? true : false
      end
  
    # Flashes related
    FLASH_TYPES = [:notice, :info, :error, :success, :warning, :custom]
  
    def display_flash(type = nil, options = nil)
      if flash then
        # Parse options:
        if (options) then 
          timeout = (options[:timeout]) ? options[:timeout] : APP.setting('flash.timeout')
          cssclass = (options[:css_class]) ? options[:css_class] : nil
          msg = (options[:msg]) ? options[:msg] : nil
          partial = app_partial((options[:partial]) ? options[:partial] : 'results/flash')
          use_partial = (options[:use_partial] || options[:use_partial] == false) ? false : true
          prefix = (options[:prefix]) ? options[:prefix] : ''
          closeable = (!options[:closeable].nil?) ? options[:closeable] : true
          delete = (!options[:delete].nil?) ? options[:delete] : false
        else 
          timeout = APP.setting('flash.timeout')
          cssclass = nil
          msg = nil
          partial = app_partial('results/flash')
          use_partial = true
          prefix = ''
          closeable = true
          delete = false
        end
        
        # Determine type
        if (type && ((type.is_a? String) || (type.is_a? Symbol)) && (flash[type] || flash[type.to_sym])) then
          # Display specific type
            flashmsg = (msg) ? msg : ((delete) ? flash.delete(type.to_sym) : flash[type.to_sym])
            flashcssclass = (cssclass) ? cssclass : 'flash_'+type.to_s
            if use_partial then
              render :partial => partial, :locals => {:type => type, :msg => prefix + ' ' + flashmsg, :timeout => timeout, :css_class => flashcssclass, :closeable => closeable}, :layout => nil
            else
              content_tag(:div, content_tag(:p , flashmsg, :class => 'message'), :class => 'flash '+flashcssclass, :id => dom_uuid)
            end
        end
      end
    end
  
    def display_flashes(options = nil)
      if flash then
        # Parse options
        if (options) then
          timeout = (options[:timeout]) ? options[:timeout] : APP.setting('flash.timeout')
          cssclass = (options[:css_class]) ? options[:css_class] : nil
          title = (options[:title]) ? options[:title] : nil
          partial = app_partial((options[:partial]) ? options[:partial] : 'results/flashes')
          closeable = (options[:closeable]) ? options[:closeable] : true
          delete = (options[:delete]) ? options[:delete] : false
        else
          timeout = APP.setting('flash.timeout')
          cssclass = nil
          title = nil
          partial =  app_partial("results/flashes")
          closeable = true
          delete = false
        end
        
        if flash.size > 1 then
          # Display all types
          res = ""
          FLASH_TYPES.each do |flashtype|
              if (flash[flashtype]) then
                res << display_flash(flashtype, {:delete => delete, :timeout => 0, :closeable => false, :prefix => content_tag(:span, '['+flashtype.to_s+']', :class => 'flashtype flash_'+flashtype.to_s)})
              end
          end
          render :partial => partial, :locals => {:title => title, :timeout => timeout, :closeable => closeable, :css_class => cssclass, :flashes => res}, :layout => nil
        else
          display_flash(flash.keys.first, options)
        end
      end
    end
  
    # Assets related
    def stylesheet(styles, media = 'screen', type = :external)
      case type
        when :external
          content_for :head do
            if styles.class == String
              stylesheet_link_tag(asset_path(styles, :style), :media => media)
            else 
              output = ''
              if styles.class == Array then
                styles.each do |stylesheet|
                  if stylesheet.class == Array && stylesheet.length == 2 then
                     output << stylesheet_link_tag(asset_path(stylesheet[0], :style), :media => stylesheet[1])
                  else
                     output << stylesheet_link_tag(asset_path(stylesheet, :style), :media => media)
                  end
                end
              end
              output
            end
          end
        when :import
          content_for :head do
            output = %{\n<style type="text/css">}
            if styles.class == String
               output << %{@import url("#{styles}") #{media};}
            else
              if styles.class == Array then
                styles.each do |stylesheet|
                  if stylesheet.class == Array && stylesheet.length == 2 then
                    output << %{@import url("#{stylesheet[0]}") #{stylesheet[1]};\n}
                  else
                    output << %{@import url("#{stylesheet}") #{media};\n}
                  end
                end
              end
            end
            output << %{</style>}
            output
          end
        when :style
          content_for :head do
            %{\n<style type="text/css" media="#{media}"><!-- #{styles.to_s.squish} --></style>}
          end
      end
    end
    
    def javascript(scripts, before = false)
      content_for ((before) ? :javascript_before_auto_include : :javascript) do
        if (scripts.class == Array || (scripts.class == String && File.extname(scripts.to_s) == '.js')) then
          if scripts.class == Array then
             #javascript_include_tag(scripts)
             output = ''
             scripts.each {|k, v|
               output << javascript_include_tag(asset_path(k.to_s, :script))
             }
             output
          else
            javascript_include_tag(asset_path(scripts.to_s, :script))
          end
        else
          javascript_tag(scripts.to_s)
        end
      end
    end
    
    def using_javascript(scripts)
      
    end
    
    def stylesheet_folder()
      
    end
    
    def javascript_folder()
      
    end
    
    def js(data)
      if data.respond_to? :to_json
        data.to_json
      else
        data.inspect.to_json
      end
    end
    
    def selector(obj)
      js "##{dom_id(obj)}"
    end
    
    # Utils
    @@partial_folder = '_application/'
     
    def app_partial(file)
      @@partial_folder+file
    end

    def render_app_partial(file, opts = {})
      render opts.merge({:partial => @@partial_folder+file})
    end
    
    def autotab
      @current_tab ||= 0
      @current_tab += 1
    end
    
    def meta_tags
      @meta_tags.map do |key,value|
        extra = ''
        if value[:extra].class == Hash && value[:extra] then
          value[:extra].map do |name,val|
            extra << " #{name}=\"#{val}\""
          end
        end
        "<meta #{value[:type]}=\"#{key}\" content=\"#{value[:content]}\"#{extra} />"
      end.join("\n")
    end
    
    def dom_uuid
      UUID.timestamp_create().to_s22.downcase
    end
  
    def limit(str="", len = 255, suffix = '...')
      (!str.blank?) ? str[0, len]+suffix : ''
    end
  
    def c(str="")
      if RAILS_ENV == "production"
        ""
      else
        str = yield if block_given?
        "<!-- #{str} -->"
      end
    end
    
    def linkrow(value, *args)
      options = args.extract_options!
      css_class = options.delete(:class) || ''
      if !value.blank? then
        subject = (['Fixnum', 'String'].include?(value.class.to_s)) ? (options.delete(:subject) || '') : value.class.to_s.downcase
        value = (['Fixnum', 'String'].include?(value.class.to_s)) ? value.to_s : value.id
        action = options.delete(:action) || 'edit'
        action = (!action.blank?) ? '_'+action : ''
        ns = options.delete(:ns) || ''
        ns = (!ns.blank?) ? ns.to_s+'_' : ''
        id = (!subject.blank? && !value.blank?) ? "id=\"#{ns}#{subject}_#{value}#{action}\"" : ''
        css_class += ' linkrow'
      end
      text = options.delete(:text)
      default = options.delete(:default) || '-'
      text = (!text.blank?) ? text : default
      %{<td class="#{css_class}" #{id}>#{text}</td>}
    end
    
    def javascript_required?
       (@js_required == nil || @js_required === true) ? true : false
    end
    
    def javascript_before
      output = ''
      debug = (production?) ? 'false' : 'true';
      output << %{window._debug = #{debug};}.squish
      if protect_against_forgery?
        output << %{
        window._auth_token_name = "#{request_forgery_protection_token}";
        window._auth_token = "#{form_authenticity_token}";
      }.squish
      end
      javascript_tag output if output
    end
    
    def javascript_app_config
        logged_in = (logged_in?) ? 'true' : 'false'
        output = %{
          APP.namespace('Config');
          APP.Config = {
              flash_timeout: "#{APP.setting('flash.timeout')}",
              error_timeout: "#{APP.setting('error.timeout')}",
              session_timeout: "#{APP.setting('session.timeout')}",
              namespaces: #{APP.setting('app.namespaces').to_json},
              logged_in: #{logged_in}
          }
        }.squish
        javascript_tag output if output
    end
  
    def controller_class
      'section_'+controller.controller_name
    end
    
    def action_class
      'subject_'+controller.action_name
    end
    
    def controller_path
      '/'+controller.class.to_s.split('::').join('/').downcase.gsub('controller', '')
    end
    
    def support_mail_link(html_options = {})
      html_options[:subject] ||= ''
      html_options[:subject] = APP.setting('mail.subject_prefix')+' '+html_options[:subject]
      mail_to APP.setting('support.mail.address'), APP.setting('support.name')+' support', html_options
    end
    
    def app_mail_link(email, name = nil, html_options = {})
      html_options[:subject] ||= ''
      html_options[:subject] = APP.setting('mail.subject_prefix')+' '+html_options[:subject]
      mail_to email, name, html_options
    end
    
    def fieldset(legend=nil, *args, &block)
     options = args.extract_options!
     html = opts_to_html_attributes(extract_default_html!(options[:html] || {}), {:class => 'fieldset'})
     concat("<fieldset#{html}>\n#{"<legend>#{legend}</legend>" if legend}\n<div class=\"fieldset_container\">",block.binding)
     yield
     concat("\n</div>\n</fieldset>",block.binding)
    end
    
    def tabs(name, tabs, *args, &block)
      options = args.extract_options!
      param = options.delete(:param) || :tab
      @current_tab = (is_edit? && !params[param].nil?) ? params[param] : tabs.first
      default_tab = options.delete(:default)
      default_tab = (tabs.include?(@current_tab))? @current_tab : default_tab
      html = opts_to_html_attributes(extract_default_html!(options[:html] || {}), {:id => name, :class => 'tabs'})
      handler = options.delete(:handler) || ''
      if !handler.blank? then
        handler = "if (tabid != '#') {"+handler + '(tabid, tabs, tabcontainer);}'
      end
      tabs_html = ''
      tabs.each do |tab|
        tabs_html << tab_link(tab, @current_tab, default_tab, options.delete(tab.to_sym))
      end
      concat('<div class="tabcontainer">'+"<div #{html}><ul>#{tabs_html}</ul>",block.binding)
      yield
      concat("</div></div>",block.binding)
      javascript('lib/jquery/plugins/ui/jquery.idTabs.js', true)
      content_for(:javascript, javascript_tag(%{
        $j(document).ready(function(){
          var tabsettings = {
          	'start': '#{@current_tab}',
          	'click': function(tabid, tabs, tabcontainer) {
          	  res = !$j(tabid+'_tab_link').is('.disabled');
          		return res;
          	},
          	'loaded': function(tabid, tabs, tabcontainer) {
          	  #{handler}
          	}
          }
          $j("##{name} ul").idTabs(tabsettings); 
        });
      }))
    end
    
    def tab(name, *args, &block)
      options = args.extract_options!
      html = opts_to_html_attributes(extract_default_html!(options[:html] || {}), {:id => name, :class => 'tabcontent'})
      display = (name == @current_tab) ? '' : 'style="display: none;"'
      concat("<div #{html} #{display}>",block.binding)
      yield
      concat("</div>",block.binding)
    end
    
    def round(value, *args)
      options = args.extract_options!
      num = options.delete(:after) || 2
      sprintf("%.#{num}f", value)
    end
    
    def ajax_block(id, *args, &block)
      options = args.extract_options!
      css_class = options.delete(:css_class) || ''
      loadmsg = options.delete(:loadmsg) || 'Data is loading ...'
      hide = (options.delete(:hide).nil?) ? false : true
      style = (hide) ? 'style="display: none;"' : ''
      load_type = (options.has_key?(:load_type)) ? options[:load_type] : 'msg'
      if block then
        concat("<div id=\"#{id}\" class=\"ajaxblock #{css_class}\" #{style}>",block.binding)
        yield
        concat("</div>",block.binding)
      else
        default_content = '&nbsp;'
        if load_type == 'msg' then
          default_content = %{
            <table width="100%">
              <tr><td align="center">
               <table cellpadding="0" cellspacing="0" align="center" class="ajaxload">
            		<tr>
            			<td class="loadimg">&nbsp;</td>
            			<td class="loadtext">#{loadmsg}</td>
            		</tr>
            	</table>
            	</td></tr>
          	</table>
          }
        end
        
        output = %{ 
          <div id="#{id}" class="ajaxblock #{css_class}" #{style}>
            #{default_content}
        	</div>
        }
        
        if load_type == 'loader' then
          load_script = %{
            $j(document).ready(function(){
              APP.Utils.block({element: '#{id}', text: '#{loadmsg}'});
            })
          }
          javascript load_script if load_script
        end
        
        return output
      end
    end
    
    def paging_top(paging_data, *args)
      options = args.extract_options!
      paging(paging_data, :top, options)
    end
    
    def paging_bottom(paging_data, *args)
      options = args.extract_options!
      paging(paging_data, :bottom, options)
    end
    
    def paging_section(paging_data, *args, &block)
      options = args.extract_options!
      toptions = options.dup
      concat(paging(paging_data, :top, toptions),block.binding)
      yield
      concat(paging(paging_data, :bottom, options),block.binding)
    end
    
    private
    
      def paging(paging_data, type, options)
        html = extract_default_html!(options[:html] || {:id => 'paging_'+type.to_s})
        style = options.delete(:style) || 'default'
        if (!style.blank?) then
          html[:class] = html[:class].to_s+' '+style+'_pagination'
        end
        ajaxable = options.delete(:ajaxable) || false
        if ajaxable == true then
          html[:class] = html[:class].to_s+' ajaxable'
        end
        compact = options.delete(:compact) || false
        page_links = (options[:page_links].nil?) ? true : options[:page_links]
        inner_window = options[:inner_window] || 4
        outer_window = options[:outer_window] || 1
        data_html = will_paginate paging_data, {:id => true, :inner_window => inner_window, :outer_window => outer_window, :page_links => page_links}
        info_html = (compact == true) ? '' : %{<div class="paginginfo">#{page_entries_info paging_data}</div>}
        partial = options.delete(:partial) || TW::Partials::Default::PAGING_TABLE
        html = opts_to_html_attributes(html, {:class => 'paging'})
        render :inline => partial, :locals => {:html => html, :data => data_html, :info => info_html}
      end
      
      def tab_link(name, current, default, opts)
        if (opts && !opts[:disabled].nil? && opts[:disabled] == true) then
          css_class = 'disabled'
        elsif (current == name)
          css_class = 'selected'
        elsif (!current && default == name)
          css_class = 'selected'
        end
        text = (opts && opts[:text]) ? opts[:text] : name.humanize
        %{
          <li><a href="##{name}" class="tablink #{css_class}" id="#{name}_tab_link">#{text}</a></li>
        }
      end
      
      def asset_path(path, type)
        case type
          when :style
            style_path = File.basename(ActionView::Helpers::AssetTagHelper::STYLESHEETS_DIR)
            path = path.gsub('/'+style_path+'/', '')
            path = path.gsub(style_path+'/', '')
            return '/'+style_path+'/'+path
          when :script
            script_path = File.basename(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR)
            path = path.gsub('/'+script_path+'/', '')
            path = path.gsub(script_path+'/', '')
            return '/'+script_path+'/'+path
        end
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
  end
end