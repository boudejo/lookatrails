# LOAD CONFIGURATION FILE
c = YAML::load(File.open("#{RAILS_ROOT}/config/email.yml"))
  
# GENERAL
ActionMailer::Base.delivery_method = c[RAILS_ENV]['delivery_method']
ActionMailer::Base.template_root = (c[RAILS_ENV]['template_root']) ? c[RAILS_ENV]['template_root'] : "#{RAILS_ROOT}/app/views"
ActionMailer::Base.logger = (c[RAILS_ENV]['logger']) ? RAILS_DEFAULT_LOGGER : nil
ActionMailer::Base.perform_deliveries = c[RAILS_ENV]['perform_deliveries']
ActionMailer::Base.raise_delivery_errors = c[RAILS_ENV]['raise_delivery_errors']

 # SEND MAIL SETTINGS
if c[RAILS_ENV]['delivery_method'] == 'sendmail' then
  ActionMailer::Base.sendmail_settings = {
    :location => c[RAILS_ENV]['sendmail_settings']['location'],
    :arguments => c[RAILS_ENV]['sendmail_settings']['arguments'],
  }  
end

# SMTP SETTINGS
if c[RAILS_ENV]['delivery_method'] == 'smtp' then
  ActionMailer::Base.smtp_settings = {
    :address => c[RAILS_ENV]['smtp_settings']['address'],
    :port => c[RAILS_ENV]['smtp_settings']['port'],
    :domain => c[RAILS_ENV]['smtp_settings']['domain'],
    :authentication => c[RAILS_ENV]['smtp_settings']['authentication'],
    :user_name => c[RAILS_ENV]['smtp_settings']['user_name'],
    :password => c[RAILS_ENV]['smtp_settings']['password'],
    :tls => c[RAILS_ENV]['smtp_settings']['tls']
  }
end

# DEFAULTS
ActionMailer::Base.default_charset = c[RAILS_ENV]['default_charset']
ActionMailer::Base.default_content_type = c[RAILS_ENV]['default_content_type']
ActionMailer::Base.default_content_type = c[RAILS_ENV]['default_content_type']
ActionMailer::Base.default_mime_version = c[RAILS_ENV]['default_mime_version']
ActionMailer::Base.default_implicit_parts_order = c[RAILS_ENV]['default_implicit_parts_order']
ActionMailer::Base.default_url_options[:host] = c[RAILS_ENV]['default_url_options']['host']