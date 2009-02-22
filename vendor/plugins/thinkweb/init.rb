# 3th party plugins
require 'migration_helper'
require 'usesguid/usesguid'
require 'userstamp/stamper'
require 'userstamp/stampable'
require 'userstamp/userstamp'

# ThinkWeb
require 'thinkweb/mail_config'

#require "thinkweb/themes"
#ActionController::Base.send :include, TW::Themes

require "thinkweb/view_helpers"
ActionView::Base.send :include, TW::ViewHelpers

require "thinkweb/search"
require "thinkweb/error_messages"

require "thinkweb/controller_extensions"
ActionController::Base.send :include, TW::ControllerExtensions

require 'thinkweb/forms/form_builder'
ActionView::Base.send :include, TW::Forms

require 'thinkweb/forms/form_helper'
require 'thinkweb/forms/form_tag_helper'

require 'thinkweb/default_partials'

require 'thinkweb/validations'
ActiveRecord::Base.send :include, TW::Validations