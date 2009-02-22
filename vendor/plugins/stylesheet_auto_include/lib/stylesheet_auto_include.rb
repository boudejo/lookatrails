module ActionView
  module Helpers
    module AssetTagHelper
      # Checks for the existence of view related styleSheets and
      # includes them based on current controller and action name.
      # 
      # Supports the following include options
      #   Given: controller_name => "users", action_name => "new"
      # 
      # The following files will be checked for
      #   1. public/stylesheets/views/users.css
      #   2. public/stylesheets/views/users/new.css
      #   3. public/stylesheets/views/users/new-*.css
      #   4. public/stylesheets/views/users/*-new.css
      #   5. public/stylesheets/views/users/*-new-*.css
      # 
      # This allows stylesheet files to be shared between multiple views
      # an unlimited number of views can be stringed together e.g.
      # new-edit-index.css would be included in the new, edit, and index views
      
      @@ssai_path       = "#{RAILS_ROOT}/public/stylesheets/views"
      @@ssai_ext        = '.css'
      @@ssai_url        = 'views'
      @@ssai_delimiter  = '-'
      @@ssai_paths      = []
      
      def stylesheet_auto_include_tags
        @@ssai_paths = []
        return unless File.directory? @@ssai_path
        if File.exists?(File.join(@@ssai_path, controller.controller_name + @@ssai_ext))
          @@ssai_paths.push(File.join(@@ssai_url, controller.controller_name))
        end
        search_style_dir(controller.controller_name, controller.action_name)
        stylesheet_link_tag *@@ssai_paths
      end
      
      private
      def search_style_dir(cont, action)
        dir = File.join(@@ssai_path, cont)
        return unless File.directory? dir
        Dir.new(dir).each do |file|
          if File.extname(file) == @@ssai_ext
            file.split(@@ssai_delimiter).collect do |part|
              @@ssai_paths.push(File.join(@@ssai_url, cont, file)) if File.basename(part, @@ssai_ext) == action
            end
          end
        end
      end
      
    end
  end
end