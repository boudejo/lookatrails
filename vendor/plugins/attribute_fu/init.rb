ActiveRecord::Base.class_eval { include AttributeFu::Associations }
ActionView::Helpers::FormBuilder.class_eval { include AttributeFu::AssociatedFormHelper }

# monkey patch to delete error entries from association validation error hash
class ActiveRecord::Errors
  def delete(attribute)
    @errors.delete attribute.to_s
  end unless method_defined?(:delete)
end