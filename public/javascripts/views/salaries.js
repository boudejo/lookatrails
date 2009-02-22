Salary = {};

Salaries = function() {
	// internal shorthand
	var pub = {};
	// private
	  var old_params = null;
	  var calc_loaded = false;
	// setup inital state
	pub.init = function () {
		return pub;
	};
	// public vars
	pub.meta = {};
	pub.calculations = {};
	pub.employee = null;
	// public methods
	pub.setup = function(instance, calculations) {
	  pub.calculations = calculations;
	  instance.subject = 'salary';
	  instance.meta = APP.Helpers.meta(instance, pub.meta, {belongs_to: pub.employee});
	  Salary = instance;
	};
	pub.load = function(opts) {
	  loadtext = (opts.current == undefined || !opts.current) ? 'Salary' : 'Current salary';
	  APP.Ajax.load({
  		element: 	  '#employee_salary',
  		url: 		    opts.url,
  		text:       loadtext + ' is loading ...',
  		callback:   function(response, status, xhr) {
  		  old_params = pub.getParameters();
  		  Salaries.bindCalculation();
  		}
  	});
	};
	pub.loadHistory = function(opts) {
	  pub.meta.collection_url = opts.url;
    // Load salaries
  	APP.Ajax.load({
  		element: 	  '#employee_salaries',
  		url: 		    opts.url,
  		text:       'Salary history is loading ...',
  		callback:   function(response, status, xhr) {
      	// Grid binding
      	$j(document).unbind('salaries_grid_rowclick');
      	$j(document).bind('salaries_grid_rowclick', function(e, data){
      	  old_params = null;
      	  Salaries.load({url: data.path, current: $j('#'+data.parsed).is('.current')});
      	  return false;
      	});
      	// Refresh button
		    $j('#refresh_salaries').expire('click');
      	$j('#refresh_salaries').livequery('click', function(){
      		Salaries.loadHistory(opts);
      		return false;
      	});
      	// Paging
      	$j('#employee_salaries div.paging a').expire('click');
      	$j('#employee_salaries div.paging a').livequery('click', function(){
          Salaries.loadHistory({url: $j(this).attr('href')});
          return false;
        });
  		}
  	});
	};
	pub.bindCalculation = function() {
	  $j('.salary_parameter').expire();
	  $j('.salary_parameter').livequery('change blur', function(event) {
  	  Salaries.calculate();
  	});
	};
	pub.getParameters = function() {
	  return {
      salary_gross_salary: $j('#salary_gross_salary').val(),
      salary_group_insurance_perc: $j('#salary_group_insurance_perc').val(),
      salary_dkv: $j('#salary_dkv').val(),
      salary_rep_allowance: $j('#salary_rep_allowance').val(),
      salary_car_budget: $j('#salary_car_budget').val()
    }
	};
	pub.calculate = function(block) {
	  block = (block == undefined) ? true : false;
	  if (pub.calculations) {
	    parameters = pub.getParameters();
	    //if (old_params == null) { old_params = parameters; }
	    if (old_params == null || $j.param(old_params) != $j.param(parameters)) {
        if (block) { APP.Utils.block({element: '#employee_salary', text: 'Performing calculation ...'}) }
        // Process calculations
        calculated_vals = {};
        constants = {};
        $j.each(pub.calculations.calculations, function() {
          calculation = this;
          calc_result = 0
          if (calculation.param === true) {
            value = parseFloat($j('#salary_'+calculation.name).val());
            if (calculation.name == 'gross_salary') {
              if (value > $j('#max').val()) {
                value = $j('#max').val();
                $j('#salary_'+calculation.name).val(value);
              } else if (value < $j('#min').val()) {
                value = $j('#min').val();
                $j('#salary_'+calculation.name).val(value);
              }
            } 
            if (value != null) { constants[calculation.name] = value; }
            calc_result = value;
          } else {
            value = APP.Utils.isset(calculation.value) ? calculation.value : null;
            if (value != null) { constants[calculation.name] = value; }
            calc_parts = calculation.calc.split(' ');
            calc = '';
            $j.each(calc_parts, function() {
                calc += ($j.inArray(this[0], pub.calculations.operators) != -1) ? this : '';
                calc += (this == 'value') ? value : '';
                calc += (APP.Utils.isset(calculated_vals[this])) ? calculated_vals[this] : '';
                if (this.indexOf('_value') != -1 && APP.Utils.isset(constants[this.replace(/_value/, '')])) {
                  calc += constants[this.replace(/_value/, '')];
                }
                if (this.indexOf('_value') != -1 && APP.Utils.isset(pub.calculations.joblevels[this.replace(/_value/, '')])) {
                  calc += pub.calculations.joblevels[this.replace(/_value/, '')];
                }
                if (this.indexOf('[') != -1 && this.indexOf(']') != -1) {
                  calc += this.replace(/\[/,"").replace(/\]/,"");
                }
                return true;
            });
            if (calc != '') {
              try {
                calc_result = parseFloat(eval(calc)).toFixed(2);
              } catch (e) {
              }
            } 
          }
          calculated_vals[calculation.name] = calc_result;
          if (APP.Utils.isset(calculation.as)) {
            if (calculation.as == 'percentage') {
              calc_result = parseFloat(calc_result) * 100
            }
          }
          if (calculation.param != true) { $j('#'+calculation.name).val(parseFloat(calc_result).toFixed(2)); }
          return true;
        });
        $j('#salary_grand_total').val((APP.Utils.isset(calculated_vals['grand_total'])) ? calculated_vals['grand_total'] : 0);
        $j('#salary_daily_cost').val((APP.Utils.isset(calculated_vals['daily_cost'])) ? calculated_vals['daily_cost'] : 0);
	      if (block) { $j('#employee_salary').unblock(); }
	      old_params = parameters;
      }
	  }
	};
	pub.create = function(frm) {
	  pub.calculate(false);
	  $j('#employee_salary input[@name=_method]').attr('disabled', 'disabled');
	  $j('#employee_salary input[@name=_method]').attr('readonly', 'readonly');
	  
	  
	  APP.Ajax.submit({
      url:                pub.employee.meta.show.url+'/salaries',
	    data:               $j(frm).formSerialize(),
	    button:             '#salary_submit_new',
	    block:              {element: '#employee_salary', text: 'Submitting salary data ...'},
	    error_container:    {element: '#employee_salary', target: '#employee_salary', type: 'prepend', field_errors: true},
	    flash_container:    {target: '#employee_salary', type: 'prepend'},
	    dataType:           'json',
	    handle_validation:  true,
      callback:           function(data, status) {
	      if (data.result == 'success') {
	        Salaries.load({url: data.path, current: true})
	        Salaries.loadHistory({url: pub.meta.collection_url});
	      }
	    }
	  });
	  Salaries.bindCalculation();
	  return false;
	};	
	pub.update = function(frm) {
	  pub.calculate(false);
	  $j('#employee_salary input[@name=_method]').removeAttr('disabled');
	  $j('#employee_salary input[@name=_method]').removeAttr('readonly');
    APP.Ajax.submit({
	    form:               frm,
	    button:             '#salary_submit_update',
	    result_container:   '#employee_salary',
	    block:              {element: '#employee_salary', text: 'Submitting salary data ...'},
	    flash_container:    {target: '.tabcontainer', type: 'prepend'},
	    dataType:           'html',
	    callback:           function() {
	      Salaries.loadHistory({url: pub.meta.collection_url});
	    }
	  });
	  Salaries.bindCalculation();
	  return false;
	};
	return pub;
}().init();