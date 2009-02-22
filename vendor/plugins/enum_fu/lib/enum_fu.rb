module EnumFu
  def self.included(including_class)
    including_class.class_eval do
 
      # make a enum colume in active record model
      # db schema
      #   create_table 'users' do |t|
      #   t.column 'role', :integer, :limit => 2
      #   end
      #
      # model
      #   class User < ActiveRecord::Base
      #   acts_as_enum :role, [:customer, :admin]
      #   end
      def self.acts_as_enum(name, values, *args)
        default_opts = { :named_scopes => false, :dependencies => nil, :store_as => :int, :labels => nil, :default_when_nil => nil}
        opts = default_opts.merge(args.extract_options!)
        
        # Reset changed-Flag after any save
        after_save '@enum_changed = false'
        
        # keep original name in n to use later,
        # I don't know why, but name's value is changed later
        n = name.to_s.dup
 
        # CONSTANTS & SINGLETON METHODS:
        # ------------------------------
        
        # create a metaclass where singleton methods can be attached to
        metaclass = class << self
          self
        end
        
        # define an array contant with the given values
        # example: Car::STATUS => [:normal, :broken, :running]
        const_name = name.to_s.upcase
        self.const_set const_name, values
 
        # define a singleton method which get the enum value
        # example: Car.status(:broken) => 1
        p1 = Proc.new { |v|
          if opts[:store_as] == :string then
            (v.blank?) ? nil : v.to_s
          else
            self.const_get(const_name).index(v) 
          end
        }
        metaclass.send(:define_method, name, p1)
 
        if (!opts[:dependencies].nil?) then
          # define an array constant with holds dependency values for each value
          # example: Car::STATUS_DEPENDENCIES => {:normal => [:broken, :running], :broken => [:normal], :running => [:normal, :broken]}
          const_dep_name = name.to_s.upcase+'_DEPENDENCIES'  
          self.const_set const_dep_name, opts[:dependencies]
      
          # define a singleton method which get the enum value
          # example: Car.status(:broken) => 1
          p2 = Proc.new { |v| self.const_get(const_dep_name)[v] }
          metaclass.send(:define_method, name.to_s+'_dependency', p2)
        end
        
        if (!opts[:labels].nil?) then
          # define an array constant with holds the label values for each value
          # example: Car::STATUS_LABELS => [nil, 'Broken/Need repair', 'Running']
          const_labels_name = name.to_s.upcase+'_LABELS'  
          self.const_set const_labels_name, opts[:labels]

          # define a singleton method which get the enum label
          # example: Car.status_label(:normal) => 'Normal'
          # example2: Car.status_label(:broken) => 'Broken/Need repair'
          p3 = Proc.new { |v|
            attr_value = self.const_get(const_name).index(v)
            if !self.const_get(const_labels_name)[attr_value].nil? then
              self.const_get(const_labels_name)[attr_value].to_s
            else
              v.to_s.humanize
            end 
          }
          metaclass.send(:define_method, name.to_s+'_label', p3)
        end
        
        # define a singleton method which get the enum labels for a dependency
        # example: Car.status_dependency_labels(:normal) => ['Broken/Need repair', 'Running']
        if (!opts[:dependencies].nil? && !opts[:labels].nil?) then
          p4 = Proc.new { |v|
            dependencies = self.const_get(const_dep_name)[v]
            labels = []
            if !dependencies.nil? then
              dependencies.each do |key|
                attr_value = self.const_get(const_name).index(key)
                if !self.const_get(const_labels_name)[attr_value].nil? then
                  labels.push(self.const_get(const_labels_name)[attr_value].to_s)
                else
                  labels.push(key.to_s.humanize)
                end
              end
            end
            (labels.size > 0) ? labels : nil
          }        
          metaclass.send(:define_method, name.to_s+'_dependency_labels', p4)
        end
      
        # INSTANCE METHODS:
        # -----------------
            
        # define an instance get/set methods which get/set the enum value
        # example:
        # c = Car.new :status => :normal
        # c.status => :normal
        # c.status = :broken
        #
        p5 = Proc.new {
          # After patch by Josh Goebel (Now, it will return nil when db value is nil)
          #default = !opts[:default_when_nil].nil? ? opts[:default_when_nil] : nil
          if opts[:store_as] == :string then
            attr_name = read_attribute(name.to_s)
            #attr_name.blank? ? default : attr_name.to_sym
            attr_name.blank? ? nil : attr_name.to_sym
          else
            attr_value = read_attribute(name.to_s)
            #attr_value.nil? ? default : self.class.const_get(const_name)[attr_value]
            attr_value.nil? ? nil : self.class.const_get(const_name)[attr_value]
          end
        }
        define_method name.to_sym, p5
 
        p6 = Proc.new { |value|
          # After patch by Georg Ledermann (Now it's possible to set as null Ex: c.status = nil )
          if value.blank?
            casted_value = nil
          elsif (value.is_a?(String) && value =~ /\A\d+\Z/) || value.is_a?(Integer)
            casted_value = value.to_i
          else
            casted_value = self.class.const_get(const_name).index(value.to_sym)
          end
          
          #if (!opts[:default_when_nil].nil? && casted_value.nil?) then
          #  casted_value = self.class.const_get(const_name).index(opts[:default_when_nil].to_sym)
          #end
          
          if opts[:store_as] == :string then
            if casted_value.is_a?(Integer) then
              casted_value = (casted_value.nil?) ? nil : self.class.const_get(const_name)[casted_value]
            else
              casted_value = (casted_value.nil?) ? nil : value.to_s
            end
          end
          
          if read_attribute(name.to_s) != casted_value then
            @enum_changed = true
          end
          
          write_attribute name.to_s, casted_value
        }
        define_method name.to_s+'=', p6
        
        # define a current dependency get method
        if (!opts[:dependencies].nil?) then
          p7 = Proc.new {
            attr_name = read_attribute(name.to_s)
            self.class.const_get(const_dep_name)[attr_name]
          }
          define_method "#{name}_dependency".to_sym, p7
        end
        
        # define a current label get method
        if (!opts[:labels].nil?) then
          p8 = Proc.new {
            attr_name = read_attribute(name.to_s)
            attr_value = self.class.const_get(const_labels_name).index(attr_name)
            (attr_value.nil?) ? attr_name.to_s.humanize : attr_value
          }
          define_method "#{name}_label".to_sym, p8
        end
      
        # define a current dependency labels get method
        if (!opts[:dependencies].nil? && !opts[:labels].nil?) then
          p9 = Proc.new {
            attr_value = read_attribute(name.to_s)
            attr_name = attr_value.nil? ? nil : self.class.const_get(const_name)[attr_value]
            dependencies = self.class.const_get(const_dep_name)[attr_name]
            labels = []
            if (!dependencies.nil?) then
              dependencies.each do |key|
                attr_value2 = self.class.const_get(const_name).index(key)
                if !self.class.const_get(const_labels_name)[attr_value2].nil? then
                  labels.push(self.class.const_get(const_labels_name)[attr_value2].to_s)
                else
                  labels.push(key.to_s.humanize)
                end
              end
            end
            (labels.size > 0) ? labels : nil
          }
          define_method "#{name}_dependency_labels".to_sym, p9
        end
      
        # define an instance check method
        p10 = Proc.new { |value|
          attr_value = read_attribute(name.to_s)
          attr_name = attr_value.nil? ? nil : self.class.const_get(const_name)[attr_value]
          (attr_name == value)
        }
        define_method name.to_s+'_is?', p10
        
        # define a has changed method
        p11 = Proc.new { 
          !!@enum_changed
        }
        define_method name.to_s+'_has_changed?', p11
        
        # define a values get method (filter by dependencies of current value)
        p12 = Proc.new { 
          if (!opts[:dependencies].nil?) then
            attr_name = read_attribute(name.to_s)
            (attr_name.nil?) ? self.class.const_get(const_name) : self.class.const_get(const_dep_name)[attr_name]
          else
            self.class.const_get(const_name)
          end
        }
        define_method name.to_s+'_select_values', p12
        
        # define a labels get method (filter by dependencies of current value)
        p13 = Proc.new { 
          if (!opts[:dependencies].nil?) then
            attr_name = read_attribute(name.to_s)
            values = (attr_name.nil?) ? self.class.const_get(const_name) : self.class.const_get(const_dep_name)[attr_name]
          else
            values = self.class.const_get(const_name)
          end
          labels = []
          if (!values.nil?) then
            values.each do |key|
              attr_value2 = self.class.const_get(const_name).index(key)
              if !self.class.const_get(const_labels_name)[attr_value2].nil? then
                labels.push(self.class.const_get(const_labels_name)[attr_value2].to_s)
              else
                labels.push(key.to_s.humanize)
              end
            end
          end
          labels
        }
        define_method name.to_s+'_select_labels', p13
        
        # define named scopes
        if opts[:named_scopes] then
          self.const_get(const_name).each do |key|
            attr_value = values.index(key)
            self.class_eval "
              named_scope :#{name}_is_#{key}, :conditions => {:#{name} => \"#{attr_value}\"}
            "
          end
        end
        
      end
    end
  end
end