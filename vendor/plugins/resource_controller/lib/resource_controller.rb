module ResourceController
  ACTIONS           = [:index, :show, :new_action, :create, :edit, :update, :destroy].freeze
  SINGLETON_ACTIONS = (ACTIONS - [:index]).freeze
  FAILABLE_ACTIONS  = ACTIONS - [:index, :new_action, :edit].freeze
  NAME_ACCESSORS    = [:model_name, :route_name, :object_name]  
  
  module ActionControllerExtension
    unloadable
    
    def resource_controller(*args)
      include ResourceController::Controller
      
      if args.include?(:singleton)
        include ResourceController::Helpers::SingletonCustomizations
      end
      
      set_default_flashes
    end
    
    def set_default_flashes(subject = nil)
      subject ||= object_name.humanize
    
      create.flash "#{subject} was successfully created."
      create.fails.flash_now "There was a probleming saving this record."
      #create.vfails.flash_now "There were some validation rules that didn't match for the record."

      update.flash "#{subject} was succesfully updated."
      update.nochanges.flash "#{subject} was not changed, nothing to update."
      update.fails.flash_now "#{subject} was not correctly saved, an error occured."
      #update.vfails.flash_now "There were some validation rules that didn't match for the record."

      destroy.flash "#{subject} was successfully removed."
      destroy.fails.flash "#{subject} could not be destroyed, an error occured"
    end
  end
end

require File.dirname(__FILE__)+'/../rails/init.rb' unless ActionController::Base.include?(Urligence)
