/**
 * jquery.filterlist.js
 * @author Thinkweb
 * @version 1.0
 * 
 * A plugin for easy selecting of related records when
 * callbacks for customization of default behavior
 * 
 * Currently returns only html (later json and jsonp with template support)
 */

jQuery.filtersReset = function (group) {
	el = (group) ? 'group_'+group : 'target';
	$j('.filterlist_'+el).trigger('reset');
};
jQuery.filtersDestroy = function (group) {
	el = (group) ? 'group_'+group : 'target';
	$j('.filterlist_'+el).trigger('destroy');
};
jQuery.filtersSetData = function (data, replace, group) {
	el = (group) ? 'group_'+group : 'target';
	$j('.filterlist_'+el).trigger('setdata', [data, replace]);
};
jQuery.filtersReinit = function (group) {
	el = (group) ? 'group_'+group : 'target';
	$j('.filterlist_'+el).trigger('reinit');
};
jQuery.filterSetValues = function (data, group) {
	el = (group) ? 'group_'+group : 'target';
	$j('.filterlist_'+el).trigger('setvalues', data);
};

(function($) {
	
	$.fn.extend({
		filterlist: function(options) {
			options = $.extend({}, $.Filterlist.defaults, {}, options);
			return this.each(function() {
				new $.Filterlist(this, options);
			});
		},
		filterReload: function(data, url) {
			return this.trigger("filter", [data, url]);
		},
		filterReset: function() {
			return this.trigger("reset");
		},
		filterClose: function() {
			return this.trigger("close");
		},
		filterDestroy: function() {
			return this.trigger("destroy");
		},
		filterSetData: function(data, replace) {
			return this.trigger("setdata", [data, replace]);
		},
		filterReInit: function() {
			return this.trigger("reinit");
		},
		filterSetValues: function(data) {
			return this.trigger("setvalues", data);
		}
	});
	
	$.Filterlist = function(input, options){
		// Create a reference of the object
			var $input = $j(input);
			var uniqueid = $j.uuid();
			var hidden = true;
			var loaded = false;
			var old_options = null;
			
			if ($j(input).attr('id')) {
				var selector = 'id';
				// element has id
				if (options.parseID === true && options.subject == null) {
					info = APP.Utils.parseDomID($j(input).attr('id'));
					var subject = info['subject'];
					var module = (options.module) ? options.module : info['module'];
				} else {
					var subject = (options.subject) ? options.subject : $j(input).attr('id');
					if (options.module) {
						var module = options.module;
					} else {
						var module = (options.subject) ? Inflector.pluralize(options.subject) : '';
					}
				}
			} else {
				// element has no id (probably through class, multiple items)
				var selector = 'class';
				var subject = (options.subject) ? options.subject : 'filter';
				$j(input).attr('id', subject+'_'+uniqueid);
				var module = (options.module) ? options.module : '';
			}
			
		// Bind events
			$input.bind("filter", function(type, data, url) {
				return filter($.extend({}, options.ajaxsettings.data, data), url);
			}).bind("reset", function() {
				return reset();
			}).bind("close", function() {
				return close();
			}).bind("destroy", function() {
				return destroy();
			}).bind("setdata", function(type, data, replace) {
				return setData(data, replace);
			}).bind("reinit", function(type) {
				return init(true);
			}).bind("setvalues", function(type, data) {
				return setValues(data);
			});
			
			init();
			
		// Filterlist specific functions
			/**
			 * Initializes the filterlist
			 */
			function init(reload) {
				if (!loaded) {
					createHandlerElements();
					bindHandlerElements();
					if ($j($input).val()) {
						$j('#' + getElementID('reset')).show();
						$j('#' + getElementID('status')).html($j(input).attr('title'));
						$j($input).data('data', {id: $j(input).val(), text: $j(input).attr('title')});
					}
					$j($input).addClass('filterlist_target');
					if (options.group) {
						$j($input).addClass('filterlist_group filterlist_group_'+options.group);
					}
					loaded = true;
				}
				if (reload === true) {
					options = old_options || options;
				}
			};
			/**
			 * Appends or replaces data for the request 
			 * 
			 * @param {Object} data
			 * @param {Object} replace
			 */
			function setData(data, replace) {
				if (loaded) {
					old_options = APP.Utils.clone(options);
					if (replace === true) {
						options.ajaxsettings.data = data;
					} else {
						options.ajaxsettings.data = $.extend({}, options.ajaxsettings.data, data);
					}
				}
			};
			/**
			 * Request the data and loads the data in the datacontainer
			 * 
			 * @param {Object} data
			 */
			function filter(data, url) {
				if (loaded) {
					containername = '#'+getElementID('datacontainer');
					if (APP.Utils.exists(containername)) {
						if (hidden) { $j('#' + getElementID('datacontainer')).fadeIn("fast") }
						empty();
					} else {
						$input.after(createElement('datacontainer', 'div', ''));
						$j('#'+getElementID('datacontainer')).css(options.datacontainer_css);
						$j('#' + getElementID('datacontainer')).fadeIn("fast");
					}
					// Configure ajaxrequest
					ajaxopts = $.extend({}, options.ajaxsettings);
					ajaxopts.element = '#'+getElementID('datacontainer');
					if (url == undefined) {
    				if (module) {ajaxopts.url = '/'+module+'/'+options.filter_action;}
    				if (typeof(options.filter_extra_params) == 'object') {
      			  ajaxopts.url += '?'+$j.param(options.filter_extra_params);
      			} else if (options.filter_extra_params) {
      				ajaxopts.url += '?'+options.filter_extra_params;
      			}
    				ajaxopts.params = $.extend({}, data, {per_page: options.per_page, filterid: $j($input).attr('id').replace("_id", ""), 
    				                                        subject: ((subject == 'filter') ? $j($input).attr('id') : subject),
    				                                        subject_class: options.subject_class, subject_text: options.subject_text});
					} else {
					  ajaxopts.url = url;
					  ajaxopts.params = data;
					}
					ajaxopts.callback = function(response, status, xhr) {
					  // bind row click
						$j('table#'+subject+'_filtergrid tr td').expire();
						$j('table#'+subject+'_filtergrid tr td').livequery('click', function(){
							rowdata = getParsedRowID($j(this).parent().attr('id'));
							if (rowdata.id == '') {
							  parent = $j(this).parent();
							  max_count = 5;
							  counter = 0;
							  while(!parent.is('.title_row') && counter < max_count) {
							    parent = $j(parent).parent();
							    counter++;
							  }
							  rowdata = getParsedRowID(parent.attr('id'));
							  rowdata.text = parent.attr('title');
							} else {
							  rowdata.text = $j(this).parent().attr('title');
							}
							setValues(options.choose($input, subject, rowdata));
							return false;
						});
						// bind pagination click
						$j('#'+getElementID('datacontainer')+' div.pagination a').expire();
						$j('#'+getElementID('datacontainer')+' div.pagination a').livequery('click', function(){
    				  filter({}, $j(this).attr('href'));
    				  return false;
    				});
    				// Close element
  					close_el = createElement('close', options.label_close_type, options.label_close);
  					$j('#'+getElementID('datacontainer')).append(close_el);
  					$j('#'+getElementID('close')).click(function() {
  						$j($input).trigger('close');
  					});
    				// create search handlers
    				createSearchHandlerElements();
    				bindSearchHandlerElements();
					};
					// Perform ajaxrequest
					APP.Ajax.load(ajaxopts);
				}
			};
			/**
			 * Sets the correct values for the selected row
			 */
			function setValues(data) {
				meta = {};
				if (typeof options.metaloadingtype == 'function') {
					alert('function');
				} else if (options.metaloadingtype == 'parserows') {
					$j('table#'+getID()+'_filtergrid tr#'+data.parsed+' td').each(function(i, o) {
						meta[$j(o).attr(options.metaloadingrowsattr)] = $j(o).text();
					});
				} else if (options.metaloadingtype == 'parseinputs') {
					$j('table#'+getID()+'_filtergrid tr#'+data.parsed+' td :hidden').each(function(i, o) {
						meta[$j(o).attr('name')] = $j(o).val();
					});
				}
				data.meta = options.metaloadingparse(meta, data, subject, options.metaloadingtype);
				// Set id and text
				data = options.formatdata(data);
				$j($input).val(data.id);
				$j('#'+getElementID('status')).html(data.text);
				if (options.closeonchoose) { close(); }
				$j('#'+getElementID('reset')).show();
				$j($input).data('data', data);
				return options.complete($input, subject, data);
			};
		// Filterlist Helper functions
			/**
			 * Creates handler elements
			 */
			function createHandlerElements() {
				// Create span element to show status
				$input.before(createElement('statcontainer', 'span', createElement('status', 'span', valueMsgText())));
				if (options.label_choose_type != 'element') {
					// Create choose element
					$input.before(createElement('choose', options.label_choose_type, options.label_choose));
				}
				if (options.label_reset_type != 'element') {
					// Create reset element
					$input.before(createElement('reset', options.label_reset_type, options.label_reset));
				} else {
					$j('#'+getElementID('statcontainer')).append(createElement('reset', 'link', options.label_reset, {class: (options.class_prefix+'_reset filter_reset_inline')}));
				}
				$j('#'+getElementID('reset')).hide();
			};
			/**
			 * Binds callbacks to handler elements
			 */
			function bindHandlerElements() {
				choose_el = (options.label_choose_type == 'element') ? 'status' : 'choose';
				$j('#'+getElementID(choose_el)).click(function(){
					$j($input).trigger('filter');
					return false;
				});
				$j('#'+getElementID('reset')).click(function(){
					$j($input).trigger('reset');
					return false;
				});
			};
			/**
			 * Creates search handler elements
			 */
			function createSearchHandlerElements() {
			  if (options.search == true) {
			    $j('#'+getElementID('datacontainer')).prepend(createElement('filtersearch', 'div', '', {class: 'filter_search'}));
			    $j('#'+getElementID('filtersearch')).prepend(createElement('filtersearchcontainer', 'div', options.searchsettings.field_label+': ', {class: 'filter_search_container'}));
			    $j('#'+getElementID('filtersearchcontainer')).append(createElement('search_val', 'text', options.searchsettings.search_val, {class: 'normal', name: 'search['+options.searchsettings.field+']'}));
			    $j('#'+getElementID('filtersearchcontainer')).append('&nbsp;');
			    $j('#'+getElementID('filtersearchcontainer')).append(createElement('search_btn', 'button', options.searchsettings.search_label, {class: 'normal', name: 'searchfilterlist'}));
			    $j('#'+getElementID('filtersearchcontainer')).append('&nbsp;');
			    $j('#'+getElementID('filtersearchcontainer')).append(createElement('reset_btn', 'button', options.searchsettings.clear_label, {class: 'normal', name: 'resetfilterlist'}));
			    if ($j('#'+getElementID('search_val')).val() == '') {
			      $j('#'+getElementID('reset_btn')).hide();
			    }
			    jQuery($j('#'+getElementID('filtersearch'))).trigger('focus');
			  }
			}	
			/**
			 * Binds callbacks to searchhandler elements
			 */
			function bindSearchHandlerElements() {
				if (options.search == true) {
				  $('#'+getElementID('search_val')).livequery('keypress', function(e){
				    var code = (e.keyCode ? e.keyCode : e.which);
            if(code == 13) { //Enter keycode
              do_search();
              return false;
            }
				  });
				  $j('#'+getElementID('search_btn')).livequery('click', function(){
  					  do_search();
  					  return false;
  				});
  				$j('#'+getElementID('reset_btn')).livequery('click', function(){
  				  options.searchsettings.search_val = '';
  					filter({});
  					return false;
  				});
				}
			};
			/**
			 * Performs search
			 */
			function do_search() {
			  if ($j('#'+getElementID('search_val')).val()) {
				  options.searchsettings.search_val = $j('#'+getElementID('search_val')).val(); 
				  search = {};
				  search['search['+options.searchsettings.field+']'] = $j('#'+getElementID('search_val')).val();
				  filter(search);
				}
				return false;
			};
			/**
			 * Sets the datacontainer empty
			 */
			function empty() {
				$j('#'+getElementID('datacontainer')).html('');
			};
			/**
			 * Hides datacontainer and reset the selected value
			 * 
			 * @param {Object} type
			 */
			function reset() {
				if (loaded) {
					$j($input).val('');
					$j('#'+getElementID('status')).html(valueMsgText());
					$j('#'+getElementID('reset')).hide();
					return options.reset($input);
				}
			};
			/**
			 * Hides datacontainer
			 * 
			 * @param {Object} type
			 */
			function close() {
				if (loaded) {
					$j('#'+getElementID('datacontainer')).fadeOut("slow");
					$j('table#'+getID()+'_filtergrid tr td').expire();
					$j('table#'+getID()+'_filtergrid tr td').unbind();
					return options.close($input);
				}
			};
			/**
			 * Removes all created elements and unbinds everything
			 */
			function destroy() {
				$j('#'+getElementID('statcontainer')).remove();
				$j('#'+getElementID('status')).remove();
				$j('#'+getElementID('reset')).remove();
				$j('#'+getElementID('reset')).unbind();
				$j('#'+getElementID('choose')).remove();
				$j('#'+getElementID('choose')).unbind();
				$j('#'+getElementID('datacontainer')).remove();
				loaded = false;
			};
			/**
			* Returns default status empty text
			*/
			function valueMsgText() {
			  return options.status_empty_msg;
			};
		// Helper functions
			function getID(strip) {
			  if (strip == true) {
			    return $j($input).attr('id').replace('_id', '');
			  } else {
				  return $j($input).attr('id');
				}
			};
			function getElementID(element) {
				return subject + '_' + uniqueid + '_' + element;
			};
			function getSubjectID(selector) {
				return (selector == 'id') ? subject : subject + '_' + uniqueid;
			};
			function getParsedRowID(id) {
				parsedID = id.replace((getSubjectID()+'_'), "");
				info = APP.Utils.parseDomID(parsedID);
				return {id: ((info.id) ? info.id : parsedID), info: info, parsed: id};
			};
			function createElement(type, eltype, value, opts) {
				opts = $.extend({}, {id: getElementID(type), 'class': options.class_prefix+'_'+type}, opts);
				types = {image: 'img', link: 'a', button: 'input', text: 'input'};
				if (eltype == 'image') {
					opts.src = value;
					opts.alt = 'filter';
					value = {};
				} else if (eltype == 'link') {
					opts.href = '#';
				} else if (eltype == 'button' || eltype == 'text') {
					opts.type = eltype;
					opts.value = value;
					value = {};
				}
				return $j.create(((types[eltype]) ? types[eltype] : eltype), opts, value);
			};
	};
	
	$.Filterlist.defaults = {
		settings: {},
		ajaxsettings: {},
		// Custom callbacks
		reset: function(input) {return true;},
		close: function(input) {return true;},
		choose: function(input, subj, data) {return data;},
		complete: function(input, subj, data) {return true;},
		formatdata: function(data) { return data;},
		paging: function() {},
		// Data
		per_page: 10,
		// Search
		search: false,
		searchsettings: {
		  field: 'name',
		  field_label: 'Name',
		  search_label: 'Search',
		  clear_label: 'Show all',
		  search_val: ''
		},
		// Labels
		label_choose_type: 'button', // button, link, image, element
		label_choose: 'Choose',
		label_reset_type: 'button', // button, link, image, element
		label_reset: 'Reset',
		label_close_type: 'button', // button, link, image
		label_close: 'X',
		// Autohandling
		parseID: true,
		subject: null,
		subject_class: '',
		subject_text: '',
		module: null,
		// Filter defaults
		filter_action: 'filter.html',
		filter_extra_params: '',
		group: '',
		status_empty_msg: 'No {subject} selected',
		class_prefix: 'filterlist',
		datacontainer_css: {
			width: '200px'
		},
		// Misc
		closeonchoose: true,
		metaloadingtype: null,	// null => {id, text}, parseinputs, parserows, custom = callback fuction
		metaloadingparse: function(meta, data, subject, loadingtype) { return meta;},
		metaloadingrowsattr: 'class',
	};
	
	$.Filterlist.Selection = function(field, start, end) {
		if( field.createTextRange ){
			var selRange = field.createTextRange();
			selRange.collapse(true);
			selRange.moveStart("character", start);
			selRange.moveEnd("character", end);
			selRange.select();
		} else if( field.setSelectionRange ){
			field.setSelectionRange(start, end);
		} else {
			if( field.selectionStart ){
				field.selectionStart = start;
				field.selectionEnd = end;
			}
		}
		field.focus();
	};
	
})(jQuery);