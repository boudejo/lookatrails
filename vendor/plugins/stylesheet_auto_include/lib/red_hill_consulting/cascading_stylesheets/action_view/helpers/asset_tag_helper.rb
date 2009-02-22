module RedHillConsulting::CascadingStylesheets::ActionView::Helpers
  module AssetTagHelper
    def self.included(base)
      base.class_eval do
        alias_method_chain :expand_stylesheet_sources, :cascade
      end
    end

    def expand_stylesheet_sources_with_cascade(sources)
      if sources.include?(:default_styles)
        sources = sources.dup
        sources.delete(:default_styles)

        candidates = []
        candidates[0] ='application'
        candidates[1] = RAILS_ENV
        candidates.insert(2, '/'+controller.active_layout) if controller.active_layout
        
        candidates.each do |source|
          sources <<  ((source[0,1] == '/') ? source[1, source.length] : source)  if File.exists?(File.join(ActionView::Helpers::AssetTagHelper::STYLESHEETS_DIR, source + '.css'))
        end
      end

      expand_stylesheet_sources_without_cascade(sources)
    end
    
  end
end
