namespace :pis do

  def next_year
    return Time.now.year+1
  end
  
  def system_user
    @system_user ||= User.system_user
  end

  desc "Calendar creation for every employee and a global calendar."
  task :create_calendars => [:timesheet_calendar, :global_calendar]

  desc "Timesheet creation for every employee."
  task :timesheet_calendar do
    puts "TIMESHEET CREATION FOR EVERY EMPLOYEE: started #{Time.now.to_s}"
    Employee.all.each do |employee|
      if Timesheet.for_employee_and_year(employee, next_year).first.nil? then
        timesheet = Timesheet.new({:employee => employee, :year => next_year, :extra_leave_days => 0, :creator => system_user, :updater => system_user})
        if timesheet.save then
          result = 'SUCCESFULLY CREATED'
        else
          result = 'ERROR SAVING'
        end
      else  
        result = 'ALREADY EXISTS'
      end
       puts "Creating #{next_year} timesheet for Employee #{employee.to_s}: << #{result} >>"
    end
    puts "TIMESHEET CREATION FOR EVERY EMPLOYEE: ended #{Time.now.to_s}\n\n"
  end

  desc "Global calendar creation."
  task :global_calendar do
    puts "PIS CALENDAR CREATION FOR YEAR #{next_year}: started #{Time.now.to_s}"
    if Calendar.for_year(next_year).first.nil? then
      calendar = Calendar.new({:year => next_year, :creator => system_user, :updater => system_user})
      if calendar.save then
        result = 'SUCCESFULLY CREATED'
      else
        result = 'ERROR SAVING'
      end
    else
      result = 'ALREADY EXISTS'
    end
    puts "Creating pis calendar #{next_year}: << #{result} >>"
    puts "PIS CALENDAR CREATION FOR YEAR #{next_year}: ended #{Time.now.to_s}\n\n"
  end

end