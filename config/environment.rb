# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.1' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]
  
  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem 'mislav-will_paginate',		:version => '>= 2.3.5', :lib => 'will_paginate',	:source => 'http://gems.github.com'
  config.gem 'RedCloth',					:version => '>= 3.0.4', :lib => 'RedCloth',			:source => 'git://github.com/jgarber/redcloth.git'
  config.gem 'haml',						:version => '>= 2.0.5', :lib => 'haml',				:source => 'git://github.com/nex3/haml.git'
  config.gem 'rubyist-aasm',				:version => '>= 2.0.2',	:lib => 'aasm',				:source => 'http://gems.github.com'
  config.gem 'yfactorial-utility_scopes',	:version => '>= 0.2.2',	:lib => 'utility_scopes',	:source => 'http://gems.github.com/'
  config.gem 'renum',						:version => '>= 1.0.2', :lib => 'renum',			:source => 'git://github.com/pkwde/renum.git'
  config.gem 'libxml-ruby',					:version => '>= 0.9.7', :lib => 'libxml',			:source => 'git://github.com/dvdplm/libxml-ruby.git'
  config.gem 'prawn',						:version => '>= 0.3.4', :lib => 'prawn',			:source => 'git://github.com/sandal/prawn.git'
  config.gem 'prawn-layout',				:version => '>= 0.1.0', :lib => 'prawn/layout',		:source => 'http://github.com/sandal/prawn-layout'
  config.gem 'prawn-format',				:version => '>= 0.1.0', :lib => 'prawn/format',		:source => 'http://github.com/sandal/prawn-format'
  

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  # Dir.glob("#{RAILS_ROOT}/app/models/*[^.rb]").each{|dir| config.load_paths << dir }
  config.load_paths << "#{RAILS_ROOT}/app/presenters/"
  config.load_paths << "#{RAILS_ROOT}/app/filters/"
  
  
  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
  # config.time_zone = 'UTC'
  config.time_zone = 'Brussels'
   
  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_quasus_session',
    :secret      => 'ca9a694db4d7149e5a9094a6eb2b339e258c8a038abba59232a9bff11e37fddf513c2d28c202f3f8eb0a2bcf915205a8e020893de1f96c75d508fa6524360e53'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :user_observer

end