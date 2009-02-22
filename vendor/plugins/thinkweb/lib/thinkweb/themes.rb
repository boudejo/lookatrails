module TW
  
  # Theme support (helper functions + view helpers)
  module Themes
    
    @@view_path = "#{RAILS_ROOT}/app/views/"
    @@view_ext = '.html.erb'
    @@theme_folder = 'themes'
    @@theme_path = @@view_path+@@theme_folder+'/' 
    @@partial_folder = 'application'
    @@partial_path = @@view_path+@@partial_folder+'/'
    @@default_theme_folder = 'themes/default'
    @@default_theme_path = @@view_path+@@default_theme_folder+'/'
    @@theme_folder = 'themes/'+APP.setting('theme.name').downcase
    @@theme_path = @@view_path+@@theme_folder+'/'
    @@layout_path = @@view_path+'layouts/'
    @@layout_theme_path = @@view_path+'themes/'
  
    protected
      
      def partial_folder(full = false)
        (full === true) ? @@partial_path : @@partial_folder
      end
      
      def partial_theme_folder(full = false)
         (full === true) ? @@theme_folder : @@theme_path
      end
      
      def theme_partial(file)
        splitted = file.split('/')
        splitted[splitted.length-1] = '_'+splitted.last+@@view_ext
        if File.exists?(@@theme_path+splitted.join('/')) then
          # /themes/[THEME]/_[FILE]
          file = @@theme_folder+'/'+file
        else
          if File.exists?(@@default_theme_path+splitted.join('/')) then
            # /themes/default/_[FILE]
            file = @@default_theme_folder+'/'+file
          else
            # /application/_[FILE]
            file= @@partial_folder+'/'+file
          end
        end
      end
      
      def render_theme_partial(file, opts = {})
        render_to_string opts.merge({:partial => theme_partial(file)})
      end
      
      def theme_folder(full = false)
        (full === true) ?  @@theme_path : @@theme_folder
      end
      
      def theme_layout(file = nil)
        if File.exists?(@@layout_path+APP.setting('theme.name').downcase+'/'+file+@@view_ext) then
          file = APP.setting('theme.name').downcase+'/'+file
        end
        file
      end
      
      def theme_stylesheet(file)
        if APP.setting('theme.name') then
          'themes/'+APP.setting('theme.name')+'/'+file
        end
      end
    
      def theme_public_layout
        theme_layout(APP.setting('theme.public_layout'))
      end
      
      def theme_login_layout
        theme_layout(APP.setting('theme.login_signup_layout'))
      end
      
      def theme_application_layout
        theme_layout(APP.setting('theme.application_layout'))
      end
      
      def theme_admin_layout
        theme_layout(APP.setting('theme.admin_layout'))
      end
    
    # Inclusion hook to make several methods availabel in views
    def self.included(base)
      base.send :helper_method, :render_theme_partial, :theme_stylesheet, :theme_partial if base.respond_to? :helper_method
    end
  end
end