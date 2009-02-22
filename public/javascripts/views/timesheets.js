Timesheet = {};

Timesheets = function() {
	// internal shorthand
	var pub = {};
	// private
	  var current_opts;
	// setup inital state
	pub.init = function () {
	  pub.meta.ns = 'pis';
	  pub.meta.base_url = '/pis/employee/[employee_id]/';
		return pub;
	};
	// public vars
	pub.meta = {};
	pub.employee = null;
	// public methods
	pub.setup = function(instance) {
	  instance.subject = 'timesheet';
	  instance.meta = APP.Helpers.meta(instance, pub.meta, {belongs_to: pub.employee});
	  Timesheet = instance;
	};
	pub.loadHistory = function(opts, showdefault) {
    // Load salaries
  	APP.Ajax.load({
  		element: 	  '#employee_timesheets',
  		url: 		    opts.url,
  		text:       'Timesheet history is loading ...',
  		callback:   function(response, status, xhr) {
      	// Grid binding
      	$j(document).unbind('timesheets_grid_rowclick');
      	$j(document).bind('timesheets_grid_rowclick', function(e, data){
      	  Timesheets.show({url: data.path});
      	  return false;
      	});
      	$j('table#timesheets_grid tr td.actions a').bind('click', function() {
    		  Timesheets.show({url: $j(this).attr('href')});
    		  return false;
    		});
      	// Refresh button
		    $j('#refresh_timesheets').expire('click');
      	$j('#refresh_timesheets').livequery('click', function(){
      		Timesheets.loadHistory(opts, false);
      		return false;
      	});
      	// Paging
      	$j('#employee_timesheets div.paging a').expire('click');
      	$j('#employee_timesheets div.paging a').livequery('click', function(){
          Timesheets.loadHistory({url: $j(this).attr('href')}, false);
          return false;
        });
        if (showdefault) {
          Timesheets.show(showdefault);
        }
  		}
  	});
	};
	pub.show = function(opts) {
	  $j('#timesheet_window').jqm({
	    overlay: 45, 
	    modal: false,
	    trigger: '.open_timesheet',
	    closeClass: '.close_timesheet',
	    onShow: function(hash) {
	      hash.w.fadeIn('3000', function() {
	        Timesheets.load(opts);
	      });
	    },
	    onHide: function(hash) {
	      hash.w.fadeOut('3000',function(){ 
	        hash.o.remove();
	        $j('#employee_timesheet').html('');
	      });
	    }
	  });
	  $j('#timesheet_window').jqmShow();
	},
	pub.load = function(opts) {
	  current_opts = opts;
	  APP.Ajax.load({
  		element: 	  '#employee_timesheet',
  		url: 		    opts.url,
  		text:       pub.employee.subject.humanize()+' timesheet is loading ...',
  		callback:   function(response, status, xhr) {
  		  Timesheets.bindEvents();
  		}
  	});
	};
	pub.bindEvents = function() {
	  $j('.close_window').expire();
	  $j('.close_window').livequery('click', function(event) {
  	  $j('#timesheet_window').jqmHide();
  	});
  	$j('.refresh_window').expire();
	  $j('.refresh_window').livequery('click', function(event) {
  	  Timesheets.load(current_opts);
  	  return false;
  	});
  	$j('a.year_nav, a.current_timesheet').expire();
	  $j('a.year_nav, a.current_timesheet').livequery('click', function(event) {
  	  current_opts.url = $j(this).attr('href');
  	  Timesheets.load(current_opts);
  	  return false;
  	});
  	$j('#employee_timesheet_calendar td.day').expire();
  	$j('#employee_timesheet_calendar td.day').livequery('click', function(event) {
  	    var rowinfo = APP.Utils.parseDomID($j(this).attr('id'));
  	    console.log(rowinfo);
  	});
	};
	pub.create = function(frm) {
	  APP.Ajax.submit({
      form:               frm,
	    button:             '#timesheet_submit_new',
	    block:              {element: '#employee_timesheet', text: 'Submitting timesheet data ...'},
	    error_container:    {element: '#employee_timesheet', target: '#employee_timesheet', type: 'prepend', field_errors: true},
	    dataType:           'json',
	    handle_validation:  true,
      callback:           function(data, status) {
	      if (data.result == 'success') {
	       //console.log('yippie !!!!!');
	       //console.log(base_url+'?year='+data.object.year);
	      }
	    }
	  });
	  return false;
	};	
	pub.update = function(frm) {
	  /*
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
	      Salaries.loadHistory({url: pub.meta.salaries_url});
	    }
	  });
	  Salaries.bindCalculation();
	  */
	  return false;
	};
	return pub;
}().init();