module TW
  
  module ControllerExtensions
    
    protected
      def system_user
        User.find_by_login('system') || false
      end
      
      def render_json(json, options={})
        callback, variable = params[:callback], params[:variable]
        response = begin
          if callback && variable
            "var #{variable} = #{json};\n#{callback}(#{variable});"
          elsif variable
            "var #{variable} = #{json};"
          elsif callback
            "#{callback}(#{json});"
          else
            json
          end
        end
        render({:content_type => :js, :text => response}.merge(options))
      end
      
      JSON_RESULTS = [:vfails, :failure, :nochanges, :success]
      
      def render_json_results(type, object={}, options={})
        result_type = (JSON_RESULTS.include?(type)) ? type.to_s : 'UNDEFINED'
        result_error = options.delete(:error) || ''
        result_msg = options.delete(:msg) || ''
        result_errors = []
        case type
          when :vfails
            result_errors = (object.respond_to?(:errors)) ? object.errors : ((!result_error.blank?) ? ['', result_error] : '') 
          when :failure
            result_errors = ((!result_error.blank?) ? ['', result_error] : []) 
        end
        result_flashes = flash
        if (options.delete(:discard_flashes) == true) then
          flash.discard
        end
        response = {:result => result_type, :action => params[:action], :object => object, :path => (options.delete(:path) || ''), :errors => result_errors, :msg => result_msg, :flashes => result_flashes}.to_json
        render({:content_type => :json, :text => response}.merge(options))
      end
    
    private
  
      # RESOURCE CONTROLLER RELATED
      
      def load_related_objects(*args)
        if args[0].class == Hash then
           objects = args[0]
        elsif args[0].class == Symbol then
           objects = Hash.new
           args.each do |subject|
             objects[subject.to_sym] = {:param => subject.to_sym, :model => subject.to_sym, :default => false}
          end
        end
        objects.each do |subject, opts|
          load_related_object(subject, opts)
        end
      end
      
      def load_related_object(subject, opts = {})
        opts || {}
        param = opts.delete(:param) || subject
        model = opts.delete(:model) || subject
        default = opts.delete(:default) || false
        param = (param.class == Symbol) ? params[param] : param
        begin
          if !param.blank? then
            @object.send("#{subject.to_s}=", Kernel.const_get(model.to_s.singularize.camelize).send(:find, param || nil))
          end
        rescue ActiveRecord::RecordNotFound
          if default == true then
            @object.send("#{subject.to_s}=", Kernel.const_get(model.to_s.singularize.camelize).send(:new))
          end
        end
      end
      
      def filter_collection(data = nil, template = nil)
        if request.xhr? then
          respond_to do |format|
            format.html {
              @subject = params[:subject]
              @subject_text = params[:subject_text]
              @subject_class = params[:subject_class]
              @filterid = params[:filterid]
              instance_variable_set "@#{object_name.to_s.pluralize}", ((data.nil?) ? collection : data)
              render :layout => false, :template => template
            }
          end
        else 
          redirect_to(collection_path) 
        end
      end
      
      # HELPERS
      
      def namespace(type = nil)
        splitted = self.class.to_s.split('::')
        splitted.pop
        ns = ''
        if (type == :url) then
           ns = '/'
           splitted.each {|x| ns << x.downcase+"/" }
        elsif (type == :tpl) then
          splitted.each {|x| ns << x.downcase+"/" }
        else
          ns = splitted.first.downcase.to_sym
        end
        return ns
      end
      
      def load_section_config
        controller = params[:controller] || ''
        sections = APP.setting('app.sections')
        section = controller.split('/').first
        section_file = "#{RAILS_ROOT}/config/sections/#{section}.yml"
        config_sections = {}
        @config = {}
        if sections.include?(section)
          if File.exists?(section_file) then
            hash = YAML::load(ERB.new(IO.read(section_file)).result)    
            config_sections.merge!(hash) {|key, old_val, new_val| (old_val || new_val).merge new_val }
            @config.merge!(config_sections[RAILS_ENV]) if config_sections.key?(RAILS_ENV)
            config_sections = nil
          end
        end
      end
      
      def default_crumb
        if @config && @config['crumb_text'] && @config['crumb_url'] then
          add_crumb @config['crumb_text'], @config['crumb_url']
        else
          crumb_text, crumb_url = APP.setting('app.crumb_text'), APP.setting('app.crumb_url')
          add_crumb crumb_text, crumb_url if crumb_text && crumb_url
        end
      end
      
      def meta_defaults
        @meta_tags = {}
        s('meta').each {|type, cat|
          cat.each {|name, value|
            if value.class == Hash then
              extra = {}
              content = ''
              value.each {|key, val|
                if (key == 'content') then
                  content = val
                else
                  extra[key] = val
                end
              }
              set_meta({:type => type, :name => name.to_s, :content => content.to_s, :extra => extra})
            else
              set_meta({:type => type, :name => name.to_s, :content => value.to_s, :extra => {}})
            end
          }
        }
      end
  
      def set_meta(default = {})
        default = {:append => false}.merge(default)
        if default[:append] === true && @meta_tags[default[:name]] then
          default[:content] = @meta_tags[default[:name]][:content]+' '+default[:content]
        end
        @meta_tags.store(default[:name], default)
      end
  
      def on_expire
        if logged_in?
          append = ''
          if params[:action] != 'destroy' && params[:controller] != 'sessions' then
            append = '?timeout=1'
          end
          if request.xhr? then
            render :inline => "
            <script type='text/javascript'>
            //<![CDATA[
              APP.Utils.onLogout();
            //]]>
            </script>" and return false
          else
            (redirect_to(login_url+append) and return false)
          end
        end
      end
    
      def invalid_token
          redirect_to(login_url+'?timeout=1')
      end
      
      def record_not_found
        render :file => File.join(RAILS_ROOT, 'public', '404.html'), :status => 404
      end
      
      def printable(val = true)
        @printable = val
      end
      
      def javascript_required(flag = true)
        @js_required = flag
      end
      
      # allows us to say "helpers." anywhere in our controllers
      def helpers
        self.class.helpers
      end
      
      # checks to see if app is in production mode
      def production?
        Rails.env == "production"
      end
      
      # Return the value for a given setting
      def s(config_value, default_value = nil)
        APP.setting(config_value, default_value)
      end
      
      # Return the value for a section setting
      def ss(config_value, default_value = nil)
        if @config then
          namespace = config_value.split('.')
          first = namespace.delete_at(0)
          param = (@config.key?(first)) ? @config[first] : '*EMPTY*'
          if param != '*EMPTY*' && namespace.length
            namespace.each{|key|
              param = (param.key?(key)) ? param[key] : '*EMPTY*'
              break if param == '*EMPTY*'
            }
          end
          (param == '*EMPTY*') ? default_value : param
        else
          default_value
        end
      end
      
      # Inclusion hook to make several methods availabel in views
      def self.included(base)
        base.send :helper_method, :s, :ss if base.respond_to? :helper_method
      end

  end
  
end