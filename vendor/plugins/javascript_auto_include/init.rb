require 'javascript_auto_include'
require 'cascading_javascripts' unless defined?(RedHillConsulting::CascadingJavascripts)

ActionController::Base.send :include, AutoIncludeScripts::ControllerMethods
ActionView::Base.send       :include, AutoIncludeScripts::ViewMethods