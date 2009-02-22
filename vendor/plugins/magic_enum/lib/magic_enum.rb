class ActiveRecord::Base
  def retrieve_from_enum(enum, val)
    type = (val.class == Symbol) ? :value : :name
    key_index = (type == :name) ? 1 : 0
    val_index = (type == :name) ? 0 : 1
    enum_value = nil
    self.class.const_get(enum).each do |k|
      if val == k[key_index] then
        enum_value = k[val_index]
        break;
      end
    end if self.class.const_get(enum)
    enum_value
  end
  
  def retrieve_enum_index(enum, val)
    type = (val.class == Symbol) ? :value : :name
    key_index = (type == :name) ? 1 : 0
    counter = nil
    self.class.const_get(enum).each do |k|
      counter = 0 if counter.nil?
      if val == k[key_index] then
        break;
      end
      counter += 1
    end
    counter
  end
end

module MagicEnum
  def self.append_features(base) #:nodoc:
    super
    base.extend(ClassMethods)
  end

  module ClassMethods
   
    def define_enum(name, int_values = nil, *args)
      default_opts = { :simple_accessors => true, :named_scopes => false, :set_default_when_nil => true, :text => []}
      opts = default_opts.merge(args.extract_options!)
      name = name.to_sym
      
      enum = (opts[:enum]) ? opts[:enum].to_s.upcase : name.to_s.pluralize.classify.pluralize.upcase
      enum_sorted = "#{enum}_SORTED"
      enum_text = "#{enum}_TEXT"
      enum_type = "#{enum}_TYPE"
      enum_name = "#{name.to_s.upcase}_ENUM_NAME"
      enum_dependency = "#{enum}_ENUM_DEPENDENCY"
      int_values.uniq! if !int_values.nil? && int_values.class == Array
      text_values = (opts[:text])
      
      values = const_get(enum)
      
      if values.class == Array then
        datasorted = []
        datatext = []
        counter=0
        values.each do |k,v|
          if int_values then
            if int_values === true then
               datasorted.push([k.to_sym, counter])
            elsif int_values.class == Array then
              if (int_values.size == values.size) then
                datasorted.push([k.to_sym, int_values[counter].to_i])
              end
            end
          else
            datasorted.push([k.to_sym, k.to_s])
          end
          datatext.push((text_values.slice(0)) ? text_values.slice!(0).to_s.humanize : k.to_s.humanize)
          counter += 1
        end
        
        opts[:default] = const_get(enum).values.sort do |a, b|
          if a.nil? and b.nil?
            0
          elsif a.nil?
            -1
          elsif b.nil?
            1
          else
            a <=> b
          end
        end.first unless opts[:default]
        
        const_set(enum_name,      enum)
        const_set(enum_sorted,    datasorted)
        const_set(enum_text,      datatext)
        const_set(enum_type,      (int_values) ? :int : :string)
        const_set(enum_dependency, opts[:depend] || {})
          
        #Define methods
          define_method name do
            self[name] || retrieve_from_enum(enum_sorted, opts[:default])
          end
                     
          define_method "#{name}_name" do
            name_val = retrieve_from_enum(enum_sorted, self[name])
            if (name_val.nil? && opts[:set_default_when_nil]) then
              name_val = opts[:default]
            end
            name_val
          end
          
          define_method "#{name}_text" do
            index = retrieve_enum_index(enum_sorted, self[name])
            self.class.const_get(enum_text).slice(index) || "#{name}_name.to_s"
          end
          
          define_method "#{name}_name_for" do |value|
            retrieve_from_enum(enum_sorted, value) || nil
          end
          
          define_method "#{name}_text_for" do |value|
            index = retrieve_enum_index(enum_sorted, value)
            self.class.const_get(enum_text).slice(index) || nil
          end
                    
          define_method "#{name}=" do |value|
            value = (self.class.const_get(enum_type) == :int) ? value.to_i : value
            exists = retrieve_from_enum(enum_sorted, value)
            if exists.nil? && opts[:set_default_when_nil] then
                self[name] = retrieve_from_enum(enum_sorted, opts[:default])
            else
                self[name] = value
            end
          end
           
          define_method "#{name}_dependencies" do |value|
            if !self.class.const_get(enum_dependency)[value].nil? then
              self.class.const_get(enum_dependency)[value]
            else
              nil
            end
          end 
           
          define_method "#{name}_values" do
            self.class.const_get(enum)
          end
          
          define_method "#{name}_sorted" do
            self.class.const_get(enum_sorted)
          end
          
          define_method "#{name}_text_values" do
            self.class.const_get(enum_text)
          end
                  
          # Accessors
          if opts[:simple_accessors] || opts[:named_scopes]
            const_get(enum).each do |key|
              define_method "#{name}_is_#{key}?" do
                send("#{name}_name") == key
              end
            end
          end
          
          # Named scopes
          if opts[:named_scopes]
            const_get(enum).each do |key|
              class_eval "
                named_scope :#{name}_is_#{key}, :conditions => {:#{name} => \"#{key}\"}
              "
            end
          end
      end
    end
      
  end
end

module ActiveRecord
  module Validations
    module ClassMethods
      
      def validates_enum(*column_names)
        opts = column_names.extract_options!
        
        cols = columns_hash
        column_names.each do |name|
          col = cols[name.to_s]
          raise ArgumentError, "Cannot find column #{name}" unless col
          
          validates_presence_of(name) if !col.null
          
          enum = const_get("#{name.to_s.upcase}_ENUM_NAME")
          raise ArgumentError, "Cannot find enum for #{name}" unless enum
          
          enum_sorted = "#{enum}_SORTED"
          enum_values = const_get(enum_sorted)
          
          case col.type
            # when :enum
            #   validates_inclusion_of name, :in => col.values, :allow_nil => true
            when :integer, :float
                validates_numericality_of name
                opts[:in] = enum_values.values
                opts[:allow_nil] = (col.null) ? true : false
                validates_inclusion_of name, opts
            when :string
                if col.limit
                  validates_length_of name, :maximum => col.limit
                end
                opts[:in] = enum_values.values
                opts[:allow_nil] = (col.null) ? true : false
                validates_inclusion_of name, opts
          end
        end
      end
      
    end
  end
end

