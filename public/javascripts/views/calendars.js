Calendar = {};

Calendars = function() {
	// internal shorthand
	var pub = {};
	// private
	  var current_opts;
	  var mode = null;
	  var config = null;
	  var period_start = null;
	  var period_end = null;
	  var entry_visible = false;
	  var help_visible = false;
	  var range_dates = null;
	// setup inital state
	pub.init = function () {
	  pub.meta.base_url = '/pis/calendars/';
		return pub;
	};
	// public vars
	pub.meta = {};
	// public methods
	pub.setup = function(instance, c_config, ac_mode) {
	  instance.subject = 'calendar';
	  instance.meta = APP.Helpers.meta(instance, pub.meta, {id: 'year'});
	  Calendar = instance;
	  config = c_config;
	  mode = ac_mode;
	};
	pub.show = function(opts) {
	  $j('#calendar_window').jqm({
	    overlay: 45, 
	    modal: false,
	    trigger: '.open_calendar',
	    onShow: function(hash) {
	      hash.w.fadeIn('3000', function() {
	        Calendars.load(opts);
	      });
	    },
	    onHide: function(hash) {
	      if ($j('#calendar_entry_window').is(':visible')) {
	        $j('#calendar_entry_window').jqmHide();
	      }
	      if ($j('#calendar_help_window').is(':visible')) {
	        $j('#calendar_help_window').jqmHide();
	      }
	      hash.w.fadeOut('3000',function(){ 
	        hash.o.remove();
	        $j('#pis_calendar_container').html('');
	      });
	    }
	  });
	  $j('#calendar_window').jqmShow();
	},
	pub.load = function(opts) {
	  current_opts = opts;
	  APP.Ajax.load({
  		element: 	  '#pis_calendar_container',
  		url: 		    opts.url,
  		text:       'Calendar is loading ...',
  		callback:   function(response, status, xhr) {
  		  Calendars.bindEvents('calendar');
  		}
  	});
	};
	pub.showHelpInfo = function() {
	  console.log('show help');
	  $j('#calendar_help_window').jqm({
	    overlay: 1, 
	    modal: true,
	    closeClass: 'close_calendar_help',
	    trigger: '.open_calendar_help',
	    onShow: function(hash) {
	      help_visible = true;
	      hash.w.fadeIn('3000', function() {});
	    },
	    onHide: function(hash) {
	      help_visible = false;
	      hash.w.fadeOut('3000',function(){
	        hash.o.remove();
	      });
	    }
	  });
	  $j('#calendar_help_window').jqmShow();
	};
	pub.handleDayClick = function(elem, info) {
    day_date = new Date (APP.Utils.MyReplace(info.id, '-', '/'));
    error = null;
    if (day_date != 'Invalid Date') {
      if (!period_start) {
        $j(elem).addClass('period_select');
        period_start = {date: day_date, info: info};
        $j('#clear_period_selection').removeAttr('disabled');
      } else if (!period_end) {
        if (day_date >= period_start.date) {
          if (config.days_select_limit != 0 && APP.Utils.daysBetween(period_start.date, day_date) > config.days_select_limit) {
            period_end = null;
            error = {msg: 'Period end date must be within '+config.days_select_limit+' days after period start.', type: 'notice'};
          } else {
            $j(elem).addClass('period_select');
            period_end = {date: day_date, info: info};
            pub.setClassForDatesBetween(period_start.date, day_date);
          }
        } else {
          period_end = null;
          error = {msg: 'Period end must be after period start.', type: 'notice'};
        }
      }
      if (period_start && period_end) {
        $j('#calendar_entry_window').jqm({
    	    overlay: 1, 
    	    modal: false,
    	    trigger: '.open_calendar_entry',
    	    onShow: function(hash) {
    	      entry_visible = true;
    	      hash.w.fadeIn('3000', function() {
    	        Calendars.loadNewEntry({start: period_start.info.id, end: period_end.info.id});
    	      });
    	    },
    	    onHide: function(hash) {
    	      entry_visible = false;
    	      hash.w.fadeOut('3000',function(){
    	        pub.clearPeriodSelection();
    	        hash.o.remove();
    	        $j('#pis_calendar_entry_container').html('');
    	      });
    	    }
    	  });
    	  $j('#calendar_entry_window').jqmShow();
      }
    } else {
      error = {msg: 'An invalid date was parsed.', type: 'error'};
    }
    pub.setStatus();
    if (error) {
      if (error.type == 'notice') { error.msg += "\nPlease select a new end period date."; }
      APP.Helpers.display_flash(error.msg, {render_type: 'modal', msg_type: error.type});
    }
	};
	pub.clearPeriodSelection = function() {
    if (!entry_visible && !help_visible) {
	    $j('#clear_period_selection').attr('disabled', 'disabled');
	    period_start = period_end = range_dates = null;
	    $j('#calendar_window table#quasus_pis_calendar td.period_select').removeClass('period_select');
	    pub.setStatus();
	  }
	};
	pub.loadNewEntry = function(params) {
	  APP.Ajax.load({
  		element: 	  '#pis_calendar_entry_container',
  		url: 		    Calendar.meta.base.url+"calendar_entries/new",
  		params:     params,
  		text:       'New calendarentry data is loading ...',
  		callback:   function(response, status, xhr) {
  		  Calendars.bindEvents('calendar_entry');
  		}
  	});
	};
	pub.createEntries = function(frm) {
	  console.log($j(frm).formSerialize());
	  /*
	  APP.Ajax.submit({
      form:               frm,
	    button:             '#calendar_entry_submit_new',
	    result_container:   '#new_'+subj+'_resource',
	    block:              {element: '#new_'+subj+'_resource', text: 'Submitting resource data ...'},
	    flash_container:    {target: '.tabcontainer', type: 'prepend'},
	    error_container:    {element: null},
	    dataType:           'html',
	    callback:           function(data, status) {
	      //$j(frm).clearForm();
	      Resources.loadList(Opportunity.meta.base.url+'resources')
	    }
	  });
    return false;
	  */
	  return false;
	};
	pub.setClassForDatesBetween = function(start, end, class) {
	  range_dates = APP.Utils.datesBetween(start, end);
    $j.each(range_dates, function(i, n){
      date_id = 'pis_calendar-entrie_'+APP.Utils.dateID(n);
      if (!$j('#'+date_id).is('.weekend')) {
        $j('#'+date_id).addClass('period_select');
      }
    });
	};
	pub.setStatus = function() {
	  var format = 'ddd dd/mm/yyyy';
	  if (period_start) {
	    if (period_end) {
	      if (period_start.date.format() == period_end.date.format()) {
	        $j('#calendar_status_container').html('Selected period: <strong>'+period_start.date.format(format)+'</strong>');
	      } else {
	        $j('#calendar_status_container').html('Selected period: <strong>from '+period_start.date.format(format)+' to '+period_end.date.format(format)+'</strong>');
	      }
	    } else {
	      $j('#calendar_status_container').html('Selected period: <strong>from '+period_start.date.format(format)+'</strong>');
	    }
    } else {
      $j('#calendar_status_container').html('Selected period: <strong>none</strong>');
    }
	};
	pub.bindEvents = function(bind_for) {
	  if (bind_for == 'calendar') {
      $j('.close_window').expire();
      $j('.close_window').livequery('click', function(event) {
    	  $j('#calendar_window').jqmHide();
    	});
    	$j('.refresh_window').expire();
      $j('.refresh_window').livequery('click', function(event) {
    	  Calendars.load(current_opts);
    	  return false;
    	});
    	$j('.help_window').expire();
      $j('.help_window').livequery('click', function(event) {
    	  Calendars.showHelpInfo();
    	  return false;
    	});
    	$j('a.year_nav, a.current_calendar').expire();
      $j('a.year_nav, a.current_calendar').livequery('click', function(event) {
    	  current_opts.url = $j(this).attr('href');
    	  Calendars.load(current_opts);
    	  return false;
    	});
    	if (mode == 'edit') {
      	$j('#quasus_pis_calendar td.day').expire();
      	$j('#quasus_pis_calendar td.day').livequery('click', function(event) {
      	    if (!entry_visible && !help_visible && !$j(this).is('.weekend')) {
      	      Calendars.handleDayClick(this, APP.Utils.parseDomID($j(this).attr('id')));
      	    }
      	});
    	} else {
    	  $j('#quasus_pis_calendar td.day').expire();
    	}
    	$j('a.close_calendar').expire();
    	$j('a.close_calendar').livequery('click', function(event) {
        $j('#calendar_window').jqmHide();
        return false;
      });
	  } else if (bind_for == 'calendar_entry') {
	    $j('a.close_calendar_entry').expire();
    	$j('a.close_calendar_entry').livequery('click', function(event) {
		    $j('#calendar_entry_window').jqmHide();
		    return false;
		  });
	  }
	};
	return pub;
}().init();