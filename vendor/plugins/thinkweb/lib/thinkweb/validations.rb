module TW::Validations
  
  def validate_date_before(comp_date)
    puts 'validate before'
    #
  end
  
  def validate_date_after(comp_date)
    puts 'validate after'
  end
  
  def validate_period(start_date, end_date, *args)
    options = args.extract_options!
    allow_equal = options.delete(:allow_equal) || false
    error_msg = options.delete(:msg) || "^ The provided period was not correct, start date must be before end date."
    
    c_start_date = ActiveRecord::ConnectionAdapters::Column.string_to_date(start_date) if !start_date.blank?
    c_end_date = ActiveRecord::ConnectionAdapters::Column.string_to_date(end_date) if !end_date.blank?
    
    if c_start_date && c_end_date then
      if allow_equal === true then
        if (c_start_date > c_end_date)  then
          errors.add_to_base error_msg
        end        
      else
        if (c_start_date > c_end_date) || (c_start_date == c_end_date)  then
          errors.add_to_base error_msg+' (equal start and end not allowed)'
        end
      end
    end
  end
  
  def validate_date_between(comp_date, start_date, end_date, allow_equal_to_start = false, allow_equal_to_end = false)
    puts 'validate between'
  end
  
end

