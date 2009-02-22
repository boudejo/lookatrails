require File.dirname(__FILE__) + '/lib/app_config'

c = AppConfig.new
c.use_file!("#{RAILS_ROOT}/config/settings.yml")
c.use_file!("#{RAILS_ROOT}/config/settings.local.yml")
c.use_section!(RAILS_ENV)
::APP = c