module Pkwde
  module HasEnum
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

       # Use like this
       #
       #   class Furniture
       #     has_enum :colors, :column_name => :custom_color_type
       #   end
      def has_enum(enum_name, options={})
        default_opts = { :named_scopes => false, :dependencies => nil, :store_as => :int, :labels => nil, :default_when_nil => nil, :allow_nil => true}
        options = default_opts.merge(options)
        
        # Reset changed-Flag after any save
        after_save '@enum_changed = false'
        
        enum_column = options.has_key?(:column_name) ? options[:column_name].to_s : "#{enum_name}_type"

        self.send("validate", "#{enum_column}_check_for_valid_type_of_enum")
        
        # throws a NameError if Enum Class doesn't exists
        enum_class = options.has_key?(:class_name) ? Object.const_get(options[:class_name].to_s.classify) : Object.const_get(enum_name.to_s.classify)

        # Enum must be a Renum::EnumeratedValue Enum
        raise ArgumentError, "expected Renum::EnumeratedValue" unless enum_class.superclass == Renum::EnumeratedValue

        # CONSTANTS & SINGLETON METHODS:
        # ------------------------------
        
        # create a metaclass where singleton methods can be attached to
        metaclass = class << self
          self
        end

        # define a singleton method which get the enum value
        # example: Car.status(:broken) => STATUS::Broken
        e1 = Proc.new { |v|
          begin
            key = enum_name.to_s.classify.to_s+'::'+v.to_s.classify.to_s
            (enum_class.include?(key.constantize)) ? key.constantize : nil
          rescue NameError => e
            nil
          end
        }
        metaclass.send(:define_method, enum_name, e1)
        
        if (!options[:dependencies].nil?) then
          # define an array constant with holds dependency values for each value
          # example: Car::STATUS_DEPENDENCIES => {:normal => [:broken, :running], :broken => [:normal], :running => [:normal, :broken]}
          const_dep_name = enum_name.to_s.upcase+'_DEPENDENCIES'  
          self.const_set const_dep_name, options[:dependencies]
      
          # define a singleton method which get the enum value
          e2 = Proc.new { |v| self.const_get(const_dep_name)[v] }
          metaclass.send(:define_method, enum_name.to_s+'_dependency', e2)
        end
        
        if (!options[:labels].nil?) then
          # define an array constant with holds the label values for each value
          # example: Car::STATUS_LABELS => [nil, 'Broken/Need repair', 'Running']
          const_labels_name = enum_name.to_s.upcase+'_LABELS'  
          self.const_set const_labels_name, options[:labels]

          # define a singleton method which get the enum label
          # example: Car.status_label(:normal) => 'Normal'
          # example2: Car.status_label(:broken) => 'Broken/Need repair'
          e3 = Proc.new { |v|
            begin
              attr_value = enum_class.const_get(v.to_s.classify.to_s).index
              if !self.const_get(const_labels_name)[attr_value].nil? then
                self.const_get(const_labels_name)[attr_value].to_s
              else
                v.to_s.humanize
              end 
            rescue NameError => e
              nil
            end
          }
          metaclass.send(:define_method, enum_name.to_s+'_label', e3)
        end
        
        # define a singleton method which get the enum labels for a dependency
        # example: Car.status_dependency_labels(:normal) => ['Broken/Need repair', 'Running']
        if (!options[:dependencies].nil? && !options[:labels].nil?) then
          e4 = Proc.new { |v|
            dependencies = self.const_get(const_dep_name)[v]
            labels = []
            if !dependencies.nil? then
              dependencies.each do |key|
                attr_value = enum_class.const_get(key.to_s.classify.to_s).index
                if !self.const_get(const_labels_name)[attr_value].nil? then
                  labels.push(self.const_get(const_labels_name)[attr_value].to_s)
                else
                  labels.push(key.to_s.humanize)
                end
              end
            end
            (labels.size > 0) ? labels : nil
          }        
          metaclass.send(:define_method, enum_name.to_s+'_dependency_labels', e4)
        end

        # INSTANCE METHODS:
        # -----------------

        define_method("#{enum_column}=") do |enum_literal|
          unless enum_literal == self[enum_column]
            self[enum_column] = enum_literal
            @enum_changed = true
          end
        end

        define_method("#{enum_name}") do
          begin
            #default = !options[:default_when_nil].nil? ? options[:default_when_nil] : nil
            if self[enum_column].blank? || !self[enum_column] then
              #return_value = self.class.send("get_enum_class_for", enum_class, enum_name, default);
              return_value = nil
            else
              return_value = enum_class.const_get(self[enum_column])
            end
            return (return_value.nil?) ? nil : return_value
          rescue NameError => e
            return nil
          rescue ArgumentError => e
            return nil
          end
        end
        
        define_method("#{enum_name}=") do |enum_to_set|
          casted_value = self.class.send("get_enum_class_for", enum_class, enum_name, enum_to_set);
          
          if casted_value.nil? then
            unless casted_value == self.send(enum_name)
              self[enum_column] = casted_value.name
              @enum_changed = true
            end
          else
             # This ensures backwards compability with the renum gem. In the
              # +pkwde-renum+ gem this comparsion bug is already fixed.
              if casted_value.kind_of?(enum_class) && enum_class.include?(casted_value)
                unless casted_value == self.send(enum_name)
                  self[enum_column] = casted_value.name
                  @enum_changed = true
                end
              else
                raise ArgumentError, "expected #{enum_class}, got #{enum_to_set.class}"
              end
          end
        end

        # validation methods
        define_method("#{enum_column}_check_for_valid_type_of_enum") do
          return true if self[enum_column].nil? || options[:allow_nil] == true
          begin
            enum_class.const_get(self[enum_column])
          rescue NameError => e
            self.errors.add(enum_column.to_sym, "Wrong type '#{self[enum_column]}' for enum '#{enum_name}'")
            return false
          end
          return true
        end
        
        # define a current dependency get method
        
        # define a current label get method
        
        # define a current dependency labels get method
        
        # define an instance check method
        
        # define a has changed method
        define_method("#{enum_name}_has_changed?") do
          !!@enum_changed
        end
        
        # define named scopes
      end
      
      def get_enum_class_for(enum_class, enum_name, value)
        begin
          if value.blank?
            casted_value = nil
          elsif (value.is_a?(String) && value =~ /\A\d+\Z/) || value.is_a?(Integer)
            casted_value = enum_class[value.to_i]
          elsif (value.is_a?(String))
            if (enum_class.include?(value.constantize)) then
              casted_value = value.constantize
            else
              casted_value = nil
            end
          elsif (value.is_a?(Symbol))
            key = enum_name.to_s.classify.to_s+'::'+value.to_s.classify.to_s
            if (enum_class.include?(key.constantize)) then
              casted_value = key.constantize
            else
              casted_value = nil
            end
          elsif (value.kind_of?(enum_class) && enum_class.include?(value))
            casted_value = value
          else
            casted_value = nil
          end
        rescue Exception => e
          casted_value = nil
        end
        return casted_value
      end
        
    end
  end
end