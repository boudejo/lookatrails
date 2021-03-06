module ActivePresenter
  # Base class for presenters. See README for usage.
  #
  class BaseMulti
    include ActiveSupport::Callbacks
    define_callbacks :before_save, :after_save
    
    class_inheritable_accessor :presented
    self.presented = {}
    class_inheritable_accessor :presented_types
    self.presented_types = {}
    
    # Indicates which models are to be presented by this presenter.
    # i.e.
    #
    #   class SignupPresenter < ActivePresenter::Base
    #     presents :user, :account
    #   end
    #
    #
    def self.presents(*types)
      types.each do |t|
        if t.class == Hash then
         t.each{|key, value|
           presented_types[key] = value
           attr_accessor key
            tname = key
            tclass = value.to_s.tableize.classify.constantize
            define_method("#{tname}_errors") do
              send(tname).errors
            end
            presented[tname] = tclass
         }
        else
          attr_accessor t
          presented_types[t] = t
          tname = t
          tclass = t.to_s.tableize.classify.constantize
          define_method("#{tname}_errors") do
            send(tname).errors
          end
          presented[tname] = tclass
        end
      end
    end
    
    def self.human_attribute_name(attribute_name)
      presentable_type = presented.keys.detect do |type|
        attribute_name.to_s.starts_with?("#{type}_")
      end
      attribute_name.to_s.gsub("#{presentable_type}_", "").humanize
    end
    
    attr_accessor :errors
    
    # Accepts arguments in two forms. For example, if you had a SignupPresenter that presented User, and Account, you could specify arguments in the following two forms:
    #
    #   1. SignupPresenter.new(:user_login => 'james', :user_password => 'swordfish', :user_password_confirmation => 'swordfish', :account_subdomain => 'giraffesoft')
    #     - This form is useful for initializing a new presenter from the params hash: i.e. SignupPresenter.new(params[:signup_presenter])
    #   2. SignupPresenter.new(:user => User.find(1), :account => Account.find(2))
    #     - This form is useful if you have instances that you'd like to edit using the presenter. You can subsequently call presenter.update_attributes(params[:signup_presenter]) just like with a regular AR instance.
    #
    # Both forms can also be mixed together: SignupPresenter.new(:user => User.find(1), :user_login => 'james')
    #   In this case, the login attribute will be updated on the user instance provided.
    # 
    # If you don't specify an instance, one will be created by calling Model.new
    #
    def initialize(args = {})
      args ||= {}
      
      presented.each do |type, klass|
        send("#{type}=", args[type].is_a?(klass) ? args.delete(type) : klass.new)
      end
      
      self.attributes = args
    end
    
    # Set the attributes of the presentable instances using the type_attribute form (i.e. user_login => 'james')
    #
    def attributes=(attrs)
      attrs.each { |k,v|
        if presented_types[k.to_sym] then
         v.each {|k2,v2|
           presentable    = k.to_sym
           presentable_type = presented_types[k.to_sym]
           flat_attribute = {k2 => ''} #remove_att... normally takes a hash, so we use a ''
           send("#{k}_#{k2}=", v2) unless presentable_type.to_s.tableize.classify.constantize.new.send(:remove_attributes_protected_from_mass_assignment, flat_attribute).empty?
         }
        else
          presentable    = presentable_for(k)
          if presentable then
            flat_attribute = {flatten_attribute_name(k, presentable) => ''} #remove_att... normally takes a hash, so we use a ''
            send("#{k}=", v) unless presentable.to_s.tableize.classify.constantize.new.send(:remove_attributes_protected_from_mass_assignment, flat_attribute).empty?
          else
            send("#{k}=", v)
          end
        end
      }
    end
    
    # Makes sure that the presenter is accurate about responding to presentable's attributes, even though they are handled by method_missing.
    #
    def respond_to?(method)
      presented_attribute?(method) || super
    end
    
    # Handles the decision about whether to delegate getters and setters to presentable instances.
    #
    def method_missing(method_name, *args, &block)
      presented_attribute?(method_name) ? delegate_message(method_name, *args, &block) : super
    end
    
    # Returns an instance of ActiveRecord::Errors with all the errors from the presentables merged in using the type_attribute form (i.e. user_login).
    #
    def errors
      @errors ||= ActiveRecord::Errors.new(self)
    end
    
    # Returns boolean based on the validity of the presentables by calling valid? on each of them.
    #
    def valid?
      presented.keys.each do |type|
        presented_inst = send(type)
        merge_errors(presented_inst, type) unless presented_inst.valid?
      end
      
      errors.empty?
    end
 
    # Returns boolean based on whether the object has been changed by calling changed? on each of them.
    #
    def changed?
      changed = false
      
      presented.keys.each do |type|
        presented_inst = send(type)

        changed = presented_inst.changed?
        break if changed
      end

      changed
    end
    
    # Calls destroy on each of the objects
    #
    def destroy
      presented.keys.each do |type|
        presented_inst = send(type)
        presented_inst.destroy
      end
    end
    
    # Calls destroy on each of the objects
    #
    def destroy!
      presented.keys.each do |type|
        presented_inst = send(type)
        presented_inst.destroy!
      end
    end
    
    # Calls restore on each of the objects
    #
    def restore!
      presented.keys.each do |type|
        presented_inst = send(type)
        presented_inst.restore!
      end
    end
    
    # Save all of the presentables, wrapped in a transaction.
    # 
    # Returns true or false based on success.
    #
    def save
      saved = false
      
      ActiveRecord::Base.transaction do
        if valid? && run_callbacks_with_halt(:before_save)
          saved = presented_instances.map { |i| i.save(false) }.all?
          raise ActiveRecord::Rollback unless saved # TODO: Does this happen implicitly?
        end
      end
      
      run_callbacks_with_halt(:after_save) if saved
      
      saved
    end
    
    # Save all of the presentables, by calling each of their save! methods, wrapped in a transaction.
    #
    # Returns true on success, will raise otherwise.
    # 
    def save!
      raise ActiveRecord::RecordNotSaved unless run_callbacks_with_halt(:before_save)
      
      ActiveRecord::Base.transaction do
        valid? # collect errors before potential exception raise
        presented_instances.each { |i| i.save! }
      end
      
      run_callbacks_with_halt(:after_save)
    end
    
    # Update attributes, and save the presentables
    #
    # Returns true or false based on success.
    #
    def update_attributes(attrs)
      self.attributes = attrs
      save
    end
    
    protected
      def presented_instances
        presented.keys.map { |key| send(key) }
      end
      
      def delegate_message(method_name, *args, &block)
        presentable = presentable_for(method_name)
        send(presentable).send(flatten_attribute_name(method_name, presentable), *args, &block)
      end
      
      def presentable_for(method_name)
        presented.keys.detect do |type|
          method_name.to_s.starts_with?(attribute_prefix(type))
        end
      end
    
      def presented_attribute?(method_name)
        p = presentable_for(method_name)
        !p.nil? && send(p).respond_to?(flatten_attribute_name(method_name,p))
      end
      
      def flatten_attribute_name(name, type)
        name.to_s.gsub(/^#{attribute_prefix(type)}/, '')
      end
      
      def attribute_prefix(type)
        "#{type}_"
      end
      
      def merge_errors(presented_inst, type)
        presented_inst.errors.each do |att,msg|
          errors.add(attribute_prefix(type)+att, msg)
        end
      end
      
      def run_callbacks_with_halt(callback)
        run_callbacks(callback) { |result, object| result == false }
      end
  end
end
