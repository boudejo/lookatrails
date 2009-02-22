# ------------------------------------------------------------------------------------------------------------------------------
# EXTENSIONS
# ------------------------------------------------------------------------------------------------------------------------------
# Extends ActiveRecord with:
# - default named scopes: http://www.pathf.com/blogs/2008/06/more-named-scope-awesomeness/
# - concerned_with functionality: http://paulbarry.com/articles/2008/08/30/concerned-with-skinny-controller-skinny-model
# - forwardable extension: http://blog.jayfields.com/2007/02/ruby-forwardable-addition.html

class << ActiveRecord::Base
  def concerned_with(*concerns)
    concerns.each do |concern|
      require_dependency "#{name.underscore}/#{concern}"
    end
  end
end

class ActiveRecord::Base
  def dom_path(sep = '_')
    self.class.to_s.downcase + sep + self.id.to_s
  end
  
  def extract_options_from_args!(args)
    if args.last.is_a?(Hash) then args.pop else {} end
  end
  
  def saved?
    !new_record?
  end
  
  def change_asset_folder(from, to)
    if self.respond_to?(:asset_folder) && self.respond_to?(:asset_folder_name) then
      if from != to then
        asset_folder_path     = RAILS_ROOT+"/public/assets/#{self.class.to_s.pluralize.downcase}/"
        asset_folder_path_to  = asset_folder_path+self.asset_folder_name(to)+"/"
        asset_folder_path_was = asset_folder_path+self.asset_folder_name(from)+"/"
        if !File.exists?(asset_folder_path_to) then
          if File.exists?(asset_folder_path_was) then
            File.rename(asset_folder_path_was, asset_folder_path_to)
          else 
            FileUtils.mkdir_p(asset_folder_path_to)
          end
        end
      end
    end
  end
  
  def set_status(status, previous = nil, date = false)
    self.status = status
    self.prev_status = previous if !previous.nil?
    self.status_change_at = Time.now if date
  end
  
  def revert_status(status)
    self.set_status(status, status)
  end
  
end

# This wil be a new feature in rails 2.2
class Module
  def delegate(*methods)
    options = methods.pop
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, "Delegation needs a target. Supply an options hash with a :to key as the last argument (e.g. delegate :hello, :to => :greeter)."
    end
 
    prefix = options[:prefix] || ''
    orig_prefix = prefix
    if prefix != true and !prefix.empty? 
      prefix += '_'
    end
    
    methods.each do |method|
      call_method = method
      if options.has_key? :method then
        method = options[:method]
      end
      if options.has_key? :default
        code = "(#{to} && #{to}.__send__(#{method.inspect}, *args, &block)) || #{options[:default].inspect}" 
      else
        code = "#{to}.__send__(#{method.inspect}, *args, &block)" 
      end

      prefix = to.to_s + '_' if orig_prefix == true
      module_eval(<<-EOS, "(__DELEGATION__)", 1)
        def #{prefix}#{call_method}(*args, &block)
          return nil unless #{to}
          #{code}
        end
      EOS
    end
  end
end

module Enumerable
  def otherwise
    empty? ? yield : self
  end
end

class Array
  def invert
    res=[]
    each do |e,i|
      res.push([i, e])
    end
    res
  end
  def keys
    res=[]
    each do |e,i|
      res.push(e)
    end
    res
  end
  def values
    res=[]
    each do |e,i|
      res.push(i)
    end
    res
  end
  def symbolize; map { |e| e.to_sym }; end
  def stringify; map { |e| e.to_s }; end
end

class String #:nodoc:
  def actionize
    self.downcase.gsub(' ', '_')
  end

  def parameterize(sep = '_')
    self.gsub(/[^a-z0-9]+/i, sep)
  end
  
  def permalinkize
    t = Iconv.new("ASCII//TRANSLIT", "utf-8").iconv(self)
    t = t.downcase.strip.gsub(/[^-_\s[:alnum:]]/, '').squeeze(' ').tr(' ', '-')
    (t.blank?) ? '-' : t
  end
end

class Float
  alias_method :orig_to_s, :to_s
  def to_s(arg = nil)
    if arg.nil?
      orig_to_s
    else
      sprintf("%.#{arg}f", self)
    end
  end
end

# ------------------------------------------------------------------------------------------------------------------------------
# DATE CONFIGURATION
# ------------------------------------------------------------------------------------------------------------------------------
# Date and time format
  date_formats = {
    :default => '%d/%m/%Y',
    :date_with_day => '%a %d/%m/%Y'
  }
  ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(date_formats)
  ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(:default => '%d/%m/%Y %H:%M')
  
# Date and time validation
  ValidatesTimeliness::Formats.remove_us_formats
  
# Apply patch for date and date input
  require 'dateformat_patch'

# ------------------------------------------------------------------------------------------------------------------------------
# ASSETS CONFIGURATION
# ------------------------------------------------------------------------------------------------------------------------------
default_scripts = [
  'lib/jquery/jquery-1.2.6',
  'lib/jquery/plugins/utils/jquery.uuid', 
  'lib/jquery/plugins/utils/jquery.domec', 
  'lib/jquery/plugins/utils/jquery.clock', 
  'lib/jquery/plugins/utils/jquery.livequery', 
  'lib/jquery/plugins/utils/jquery.jqmodal',
  'lib/jquery/plugins/utils/jquery.form',
  'lib/jquery/plugins/utils/jquery.countdown',
  #'lib/jquery/plugins/ajax/jquery.ajaxManager',
  'lib/jquery/plugins/ajax/jquery.blockUI', 
  'lib/jquery/plugins/ajax/jquery.using', 
  #'lib/jquery/plugins/utils/jquery.metadata.min', 
  'lib/jquery/plugins/ajax/jquery.history.fixed', 
  #'lib/jquery/plugins/ajax/jquery.ajaxify', 
  'lib/inflection',
  'lib/dateformat'
]

dev_scripts = [
  'lib/jquery/plugins/debug/jquery.dump'
]

default_scripts = default_scripts | dev_scripts if RAILS_ENV == 'development'

ActionView::Helpers::AssetTagHelper.register_javascript_expansion :default_scripts => default_scripts
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :default_styles => []

# ------------------------------------------------------------------------------------------------------------------------------
# MAIL CONFIGURATION
# ------------------------------------------------------------------------------------------------------------------------------
class ActionMailer::Base
  def app_setup_mail
     @from              = "#{APP.setting('mail.sender.name')} <#{APP.setting('mail.sender.address')}>"
     headers            "Reply-to" => APP.setting('mail.sender.address')
     @subject           = APP.setting('mail.subject_prefix')+' '
     @sent_on           = Time.now
     @body[:sent_on]    = Time.now
     @body[:debug_info] = ''
  end
  
  def debug_mail
    @body[:debug_info]  = %{
        DEBUG INFO:
        * receivers: #{@recipients}
    }
    @recipients         = "#{APP.setting('debug.mail.name')} <#{APP.setting('debug.mail.address')}>"
  end
end

# -------------------------------------------------------------------------------------------------------------------------------------
# SASS PLUGIN CONFIGURATION
# -------------------------------------------------------------------------------------------------------------------------------------
Sass::Plugin.options = {
  :template_location => RAILS_ROOT + "/public/sass/styles", 
  :load_paths => [RAILS_ROOT + "/public/sass/import", RAILS_ROOT + "/public/sass/import/plugins"],
  :style => (RAILS_ENV == 'development') ? :expanded : :compressed
}

# -------------------------------------------------------------------------------------------------------------------------------------
# DEFAULTS
# -------------------------------------------------------------------------------------------------------------------------------------
DEFAULT_COUNTRIES       = APP.setting('data.countries.default')

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  msg = instance.error_message
  error_style = "background-color: #f2afaf"
  if html_tag =~ /<(input|textarea|select)[^>]+style=/
    style_attribute = html_tag =~ /style=['"]/
    html_tag.insert(style_attribute + 7, "#{error_style}; ")
  elsif html_tag =~ /<(input|textarea|select)/
    first_whitespace = html_tag =~ /\s/
    html_tag[first_whitespace] = " style='#{error_style}' "
  end
  html_tag
end

