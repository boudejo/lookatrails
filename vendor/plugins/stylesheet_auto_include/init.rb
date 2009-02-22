require 'stylesheet_auto_include'
require 'cascading_stylesheets' unless defined?(RedHillConsulting::CascadingStylesheets)

ActionController::Base.send :include, AutoIncludeStyles::ControllerMethods
ActionView::Base.send       :include, AutoIncludeStyles::ViewMethods