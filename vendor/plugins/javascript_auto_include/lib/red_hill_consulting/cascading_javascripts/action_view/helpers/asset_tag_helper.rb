module RedHillConsulting::CascadingJavascripts::ActionView::Helpers
  module AssetTagHelper
    def self.included(base)
      base.class_eval do
        alias_method_chain :expand_javascript_sources, :cascade
      end
    end

     def expand_javascript_sources_with_cascade(sources)
        if sources.include?(:default_scripts)
          candidates = []
          candidates[0] = "application"
          candidates[1] = RAILS_ENV
  
          candidates.each do |source|
            sources << source if File.exists?(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, source + '.js'))
          end
        end
        expand_javascript_sources_without_cascade(sources)
    end
  end
end
