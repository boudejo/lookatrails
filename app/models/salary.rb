class Salary < ActiveRecord::Base
  
  # Behaviors
  stampable
  acts_as_paranoid
  
  # Associations
  belongs_to :employee
  
  # Delegations
  
  # Named scopes
  named_scope :ordered, :order => "current DESC, created_at ASC"
  
  # Triggers
  before_create :apply_defaults
  after_save :update_if_current
  
  # Defaults
  default_value_for :current, true
  
  # Attributes
  # Per page pagination
  cattr_reader :per_page
  @@per_page = 3
  
  # Enums
  
  # Validations
  validates_presence_of :gross_salary, :rep_allowance, :group_insurance_perc, :car_budget
  validates_numericality_of :gross_salary, :rep_allowance, :group_insurance_perc, :car_budget, :grand_total, :daily_cost
  
  def validate
    if self.saved? && !self.current? then
      self.errors.add(:salary, ' cannot be updated because it\'s not set as the current one.')
    end
  end
  
  # Instance Methods
  def to_s(type = 'current')
    case type.to_s
      when "current"
        self.current? ? 'Current Salary' : 'Salary'
      else
        super()
    end
  end
  
  def update_if_current
    if self.current? && !self.current_was then
      Salary.update_all("current = '0'", [ "employee_id = ? AND id <> ?", self.employee, self.id])
    end
  end
  
  def apply_defaults(joblevel = nil)
    joblevel ||= self.employee.joblevel
    self.gross_salary         = (self.gross_salary > 0) ? self.gross_salary : APP.setting("data.salaries.default.gross_salary.#{joblevel}.min")
    self.rep_allowance        = (self.rep_allowance > 0) ? self.rep_allowance : APP.setting("data.salaries.default.rep_allowance.#{joblevel}")
    self.group_insurance_perc = (self.group_insurance_perc > 0) ? self.group_insurance_perc : APP.setting("data.salaries.default.group_insurance_perc.#{joblevel}")
    self.car_budget           = (self.car_budget > 0) ? self.car_budget : APP.setting("data.salaries.default.car_budget.#{joblevel}")
    self.dkv                  = (self.dkv > 0) ? self.dkv : APP.setting('data.salaries.default.dkv')
    self.notes                = "Basic startsalary #{self.employee.to_s} for joblevel: #{joblevel}"
    self.grand_total          = calculate('grand_total', {}, joblevel)
    self.daily_cost           = calculate('daily_cost', {}, joblevel)
  end

  def calculate(value, calculated = {}, joblevel = nil)
    calculation = APP.setting('data.salaries.calculations.values.'+value)
    if joblevel.nil? then
      joblevel = (self.employee.nil?) ? 'unspecified' : self.employee.joblevel
    end
    if !calculation.nil? then
      param = calculation['param'] || false
      if param then
        calc_result = (self.attributes.include?(value)) ? self.attributes[value] : 0
      else
        calc_value = calculation['value'] || 0
        calc_parts = calculation['calc'].split(' ')
        calc = ''
        calc_parts.each do |calc_part|
          # Check if operator
          if Salary.operators.include?(calc_part)
            calc << "#{calc_part}" 
            next
          end
          # Check if it's a predefined constant value
          if calc_part == 'value' then
            calc << "#{calc_value}"
            next
          end
          # Check if it's a fixed value
          if calc_part.include?('[') && calc_part.include?(']') then
            calc << "#{calc_part.gsub(/\[/,'').gsub(/\]/,'')}"
            next
          end
          # Check if it is a joblevel value
          if calc_part.include?('_value') && Salary.default_salaries_for(joblevel).include?(calc_part.gsub(/_value/, '')) then
            calc << "#{Salary.default_salaries_for(joblevel)[calc_part.gsub(/_value/, '')]}" 
            next
          end
          # Check if not already calculated
          if calculated.include?(calc_part) then
            calc << "#{calculated[calc_part]}"
            next
          end
          # Check if value should be calculated
          if calc_part.include?('_value') then
            if APP.setting('data.salaries.calculations.values.'+calc_part.gsub(/_value/, '')+'.value') then
              calc_part_result = APP.setting('data.salaries.calculations.values.'+calc_part.gsub(/_value/, '')+'.value')
              calc << "#{calc_part_result}"
            end
          else
            calc_part_result = self.calculate(calc_part, calculated)
            calculated[calc_part] = calc_part_result
            calc << "#{calc_part_result}"
          end
        end
        if !calc.blank? then
          begin
            calc_result = sprintf("%.2f", eval(calc))
          rescue Exception => exc  #ZeroDivisionError
            calc_result = 0
          end
        else
          calc_result = 0
        end
      end
      if calculation.has_key?('as') then
        if calculation['as'] == 'percentage' then
          calc_result = calc_result.to_f * 100
        end
      end
      return calc_result
    else
      return 0
    end
  end

  def calculations
    calculated = []
    calculated_vals = {}
    calculation_order = APP.setting('data.salaries.calculations.order')
    calculations = APP.setting('data.salaries.calculations.values')
    calculation_order.each do |calculation_name|
      if calculations.has_key?(calculation_name) then
        calculation = calculations[calculation_name]
        param = calculation['param'] || false
        if param then
          ccs_class = "salary_parameter floatvalue #{calculation['class']}"
        else
          ccs_class = "salary_calculation #{calculation['class']}"
        end
        if calculation.has_key?('as') then
          if calculation['as'] == 'percentage' then
            ccs_class += ' percentage'
          end
        end
        calc_result = self.calculate(calculation_name, calculated_vals)
        calculated_vals[calculation_name] = calc_result
        calculated.push(calculation.merge({'name' => calculation_name, 'param' => param, 'result' => calc_result, 'class' => ccs_class, 'saveable' => (calculation['saveable'] || false) }))      
      end
    end
    calculated
  end
    
  def calculations_json
    calculations_in_json = {}
    calculations_in_json['joblevels'] = Salary.default_salaries_for(self.employee.joblevel)
    calculations_in_json['operators'] = Salary.operators
    calculations_in_json['calculations'] = []
    #calculations_in_json['calculations'] = Object.new
    calculation_order = APP.setting('data.salaries.calculations.order')
    calculations = APP.setting('data.salaries.calculations.values')
    calculation_order.each do |calculation_name|
      if calculations.has_key?(calculation_name) then
        #calculations_in_json['calculations'].instance_variable_set("@value_#{calculation_name}", calculations[calculation_name].merge({:name => calculation_name}))
        calculations_in_json['calculations'] << calculations[calculation_name].merge({:name => calculation_name})
      end
    end
    calculations_in_json.to_json
  end
  
  # Abstract methods
  def self.operators
    return ['/', '*', '(', ')', '-', '+']
  end
  
  def self.default_salaries_for(joblevel)
    return APP.setting('data.salaries.default.gross_salary')[joblevel]
  end
  
end
