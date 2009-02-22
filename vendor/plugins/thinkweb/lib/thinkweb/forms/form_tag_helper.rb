module ActionView::Helpers::FormTagHelper
  
  # A list of labelable helpers.
  def self.labelable #:nodoc:
    public_instance_methods.
    reject { |h| h =~ /form|field_set|submit|hidden/ || h =~ /_with(out)?_label/ }.
    map { |x| x.to_sym }
  end
  
  labelable.each do |helper|
    define_method "#{helper}_with_label" do |*args|
      label = extract_label_options! args
      
      handle_disparate_args! helper, args
      
      unlabeled_tag = send "#{helper}_without_label", *args
      return unlabeled_tag unless label
      
      name = args.first.to_s
      label[:text] ||= name.humanize
      label[:for]  ||= name.gsub(/[^a-z0-9_-]+/, '_').gsub(/^_+|_+$/, '')
      
      render_label_and_tag label, unlabeled_tag
    end
    
    alias_method_chain helper, :label
  end
  
  private
    # We want to account for certain optional arguments
    # that can occur before the options hash in the unlabeled helpers.
    #
    # Specifically, we want to be able to ignore them and say things like:
    #     check_box_tag :bulk_delete, :label => 'get outta here'
    def handle_disparate_args!(helper, args) #:nodoc:
      # Ignore the options hash, if present, until we are done munging the args.
      options = args.pop if args.last.is_a? Hash
    
      if args.size == 1
        if check_or_radio?(helper)
          args.insert 1, 1
        # Everything except :file_field_tag takes something as its second
        # argument which can be safely defaulted to +nil+.
        elsif helper != :file_field_tag
          args.insert 1, nil
        end
      end
    
      # :check_box_tag and :radio_button_tag can take another argument
      # to determine if they are 'checked' or not.
      if (2 == args.size) and check_or_radio?(helper)
        args.insert 2, false
      end
    
      # Reunite the options with the rest of the args.
      args << options if options
    
      args
    end
    
    # return label and tag according to custom options
    def render_label_and_tag(label, unlabeled_tag, template = self)
      if (label[:block]) then
        if label[:style] then
          label[:style] << ' display: block;'
        else
          label[:style] = 'display: block;'
        end
      end
      if (label[:inline]) then
        if label[:style] then
          label[:style] << ' display: inline;'
        else
          label[:style] = 'display: inline;'
        end
      end

      label[:title] = label[:text] if !label[:title]

      label_html = extract_label_html! label

      if label[:partial] then
        return render_label_and_tag_partial(label, unlabeled_tag, label_html, template)  
      end

      if label[:wrap]
        label_and_tag = if label[:after] or :after == label[:wrap]
          [unlabeled_tag, label[:text]]
        else
          [label[:text], unlabeled_tag]
        end.join("\n")

        template.content_tag(:label, label_and_tag, label_html)

      elsif label[:after]
        unlabeled_tag + template.content_tag(:label, label[:text], label_html)

      else
        template.content_tag(:label, label[:text], label_html) + unlabeled_tag
      end
    end

    def render_label_and_tag_partial(label, unlabeled_tag, label_html, template)
        partial = (label[:partial].class == String) ? label[:partial] : nil;
        tw_defaults = {:append_label => '', :prepend_label => '', :append_field => '', :prepend_field => '', :container => '', :style => ''}
        
        if label[:wrap]
          label_and_tag = if label[:after] or :after == label[:wrap]
            [unlabeled_tag, label[:text]]
          else
            [label[:text], unlabeled_tag]
          end.join("\n")
          label_and_tag = template.content_tag(:label, label_and_tag, label_html)
          partial ||= TW::Partials::Form::DEFAULT
          render :inline => partial, :locals => {:label => label_and_tag, :field => ''}.merge(tw_defaults)

      elsif label[:after]
        label_tag = template.content_tag(:label, label[:text], label_html)
        partial ||= TW::Partials::Form::DEFAULT_REVERSE
        render :inline => partial, :locals => {:label => label_tag, :field => unlabeled_tag}.merge(tw_defaults)
      else
        label_tag = template.content_tag(:label, label[:text], label_html)
        partial ||= TW::Partials::Form::DEFAULT
        render :inline => partial, :locals => {:label => label_tag, :field => unlabeled_tag}.merge(tw_defaults)
      end
    end

    def extract_label_options!(args, builder = false) #:nodoc:
      options = args.last.is_a?(Hash) ? args.last : {}

      label = options.delete :label

      # Default behavior for the builder is to be ON, so a missing :label option still means to use the plugin.
      # Default behavior for the tag helpers is to be OFF, so a missing :label option is like :label => false in the builder.
      if (label.nil? and !builder) or (false == label)
        return false
      end

      # From here on, we need a Hash..
      label = case label
      when Hash     then label
      when String   then { :text => label }
      when nil,true then {}
      end

      # Per the HTML spec..
      label[:for] = options[:id]

      label
    end

    def extract_label_html!(label) #:nodoc:
      [:id, :class, :for, :title, :style].inject({}) { |html,k| html.merge k => label.delete(k) }
    end

    def check_or_radio?(helper) #:nodoc:
      [:check_box_tag, :radio_button_tag].include? helper.to_sym
    end
end