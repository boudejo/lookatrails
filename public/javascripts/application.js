var $j = jQuery.noConflict();

/*
Based on YUI code (with some modifications for extending features)
Copyright (c) 2008, Yahoo! Inc. All rights reserved.
Code licensed under the BSD License:
http://developer.yahoo.net/yui/license.html
*/

/**
 * The global namespace object.
 */
if (typeof APP == 'undefined' || !APP) {
	var APP = {
		_modules: [],
		env: 'prod',
		getVersion: function(name){
			return APP.modules[name] || null;
		}
	}
};

/**
 * Returns the namespace specified and creates it if it doesn't exist
 * @method namespace
 * @static
 * @param  {String*} arguments 1-n namespaces to create 
 * @return {Object}  A reference to the last namespace object created
 */
APP.namespace = function() {
    var a=arguments, o=null, i, j, d;
    for (i=0; i<a.length; i=i+1) {
        d=a[i].split(".");
        o=APP;
        for (j=(d[0] == "APP") ? 1 : 0; j<d.length; j=j+1) {
            o[d[j]]=o[d[j]] || {};
            o=o[d[j]];
        }
    }
    return o;
};

/**
 * Registers a module
 * @method register
 * @static
 * @param {String}   name    	the name of the module
 * @param {Function} mainClass 	a reference to class in the module.
 * @param {Object}   data      	metadata object for the module.
 */
APP.register = function(name, mainClass, data) {
    var mods = APP._modules;
    if (!mods[name]) {
        mods[name] = { versions:[], builds:[] };
    }
    var m=mods[name],v=data.version,b=data.build;
    m.name = name;
    m.version = v;
    m.build = b;
    m.versions.push(v);
    m.builds.push(b);
    m.mainClass = mainClass;
    if (mainClass) {
        mainClass.VERSION = v;
        mainClass.BUILD = b;
    }
};

APP.register("Thinkweb", APP, {version: "1.0", build: "1"});

/*
 * jQuery Initialization
 */
$j(document).ready(function(){

	if (window._debug && window.console) {
		window.console.log('console debugging turned ON');
	}

	APP.env = (typeof window._debug != 'undefined' && window._debug) ? 'debug' : 'prod';
		
	/**
	 * APP Utils namespace
	 */
	APP.namespace('Utils');

	APP.Utils = function() {
		var pub = {};
		// private
			var modal_defaults = {
				type: 'message',
				element: '#app_modaldialog',
				usecustom: (typeof $j(document).jqm == 'function') ? true : false,
				title: null,
				url: null,
				custom: true,
				msg_type: 'modaltype',
				callback: null,
				callbackparams: {},
				cancelbtn: false,
				closelink: false
			};
			var block_defaults = {
				element: 'full',
				text: 'Data is loading ...',
				textcss: {backgroundColor: 'transparent', width: 'auto'},
				msg: function() {
					table = $j.create('div', {},
						$j.create('table', {'class': 'ajaxload', align: 'center'},
								$j.create('tr', {}, [
									$j.create('td', {'class': 'loadimg'}, ''),
									$j.create('td', {'class': 'loadtext'}, this.text)
								])
						)
					);
					return table.html();
				}
			};
			var logtypes = {
				screen: ['info', 'notice', 'warning', 'error', 'success', 'custom'],
				console: ['log', 'debug', 'info', 'warn', 'error']
			};
		// setup inital state
			pub.init = function () {
				$j('#currentdatetime').jclock();
				pub.initSessionTimer();
				return pub;
			};
		// public
		  pub.log = function(msg, data, src, cat) {
  			if (msg.constructor == Array) {
					techmsg = msg[0];
					msg = msg[1] || '';
				} else {
					techmsg = msg;
					msg = '';
				}
				msg = (msg === true) ? techmsg : msg;
				logmsg = techmsg+((msg && techmsg !== msg) ? "\nDisplayed: "+msg : '')
				data = data || '';
				src = (src != undefined) ? "\nsource: " + src : '';
				if (window._debug && APP.env == 'debug') {
					// console logging
					if (window.console && window.console[cat] && typeof window.console[cat] == 'function') {
						window.console[cat](logmsg, data);
					}
				} else {
					if (APP.Utils.isset(msg) && msg) {
						APP.Utils.modal('msg', msg, {title: 'Application message: ' + cat, msg_type: cat});
					}
				}
				return false;
			};
			pub.initDebugger = function() {
				$j('#app_show_debugger').bind('click', function() {
					$j('#app_debugger').toggle();
					if ($j('#app_debugger').is(':visible')) {
					}
					return false;
				});
			};
			pub.initSessionTimer = function(type, update) {
				update = pub.isset(update, false);
				if (APP.Config.session_timeout > 0) {
					timeout = new Date();
					timeout.setSeconds(timeout.getSeconds() + (APP.Config.session_timeout - 1));
					if (update === true) {
						$j('#countdown').countdown('change', {until: timeout}); 
					} else {
						$j('#countdown').countdown({
							until: timeout,
							compact: true,
							onExpiry: function(){
								if (type == 'refresh' || (APP.Config.logged_in === false)) {
									var loc = window.location.href;
								 	if (loc.indexOf('timeout=1') != -1) { loc = loc.replace(/\?timeout=1/, ''); }
								 	window.location.href = loc;
								} else if (type == 'logout' || (APP.Config.logged_in === true)) {
									alert('logout');
									//pub.onLogout();
								}
							}
						});
					}
				}
			};
			pub.onLogout = function() {
				APP.Utils.modal('message', 'The current session has timed out and you need to login again to continue !', {url: '/login?timeout=1', title: 'Session timed out'});
			};
			pub.onRowClick = function(event) {
				parid = ($j(this).is('.linkrow')) ? $j(this).attr('id') : $j(this).parent().attr('id');
				var rowinfo = pub.parseDomID(parid);
				if (!$j(this).is('.norowlink')) {
					if (($j(this).is('.linkrow') && !$j(this).is('.callback'))
						|| (!$j(this).is('.linkrow') && !$j(this).parent().is('.callback') && !$j(this).parent().is('.norowlinks'))) {
						window.location.href = rowinfo.path;
					} else if (($j(this).is('.linkrow') && $j(this).is('.callback'))
						|| (!$j(this).is('.linkrow') && $j(this).parent().is('.callback') && !$j(this).parent().is('.norowlinks'))) {
						$j(document).trigger($j(this).parent().parent().parent().attr('id')+'_rowclick', rowinfo);
					}
				}
				return true;
			};
			pub.parseDomID = function(id){
				var data = {ns:'', controller:'', id:'', action:'', path:'', parsed: id, objects: {}};
				var actions = ['new', 'show', 'edit', 'delete'];
				data.path = '/';
				var ns_info = id.split('_');
				var obj_info = id.split('_');
				$j.each(ns_info, function(i, n) {
				  if (APP.Config.namespaces.indexOf(n) != -1) {
				    if (i == 0) {
				      data.ns = n;
				    }
				    data.path += n+'/'
				    obj_info.splice(obj_info.indexOf(n), 1)
				  }
				});
				data.action = (actions.indexOf(obj_info[obj_info.length-1]) == -1) ? 'edit' : obj_info.pop();
				var object_name = '';
				var id_key = obj_info.length-1;
				var subject_key = obj_info.length-2;
				$j.each(obj_info, function(i, n) {
				  if ((i+1)%2 == 0) {
				    if (i == id_key) {
				      data.id = n;
				    }
				    data.objects[object_name] = n;
				    data.path += n+'/';
				  } else {
				    if (i == subject_key) {
				      data.controller = n.pluralize().replace('-','_');
				      data.subject = n.replace('-','_');
				    }
				    object_name = n.replace('-','_');
				    data.objects[object_name] = null;
				    data.path += object_name.pluralize()+'/';
				  }
				});
				data.path += data.action
				return data;
			};
			pub.bind = function(fn) {
				var args = [];
	  			for (var n = 1; n < arguments.length; n++) {
	    			args.push(arguments[n]);
				}
	  			return function () { return fn.apply(this, args); };
			};
			pub.bindby = function(object, method){  
				var args = Array.prototype.slice.call(arguments, 2);  
				return function() {  
					var args2 = [this].concat(args, $j.makeArray( arguments ));  
					return method.apply(object, args2);  
				};  
			}; 
			pub.modal = function(type, msg, settings) {
				modal_opts = $j.extend({}, modal_defaults, settings || {});
				modal_opts.msg_type = (pub.isset(settings.msg_type)) ? modal_defaults.msg_type+'_'+settings.msg_type : modal_opts.msg_type;
				if (type == 'confirm' && !modal_opts.title) {
					modal_opts.title = 'Please confirm';		
				}
				if (modal_opts.usecustom && modal_opts.custom) {
					$j(modal_opts.element).jqm({overlay: 45, modal: true, trigger: false});
					if (modal_opts.title) {
						$j(modal_opts.element).jqmShow().find('div.app_modaldialogwindowtitle h1').html(modal_opts.title);
					} else {
						$j(modal_opts.element).jqmShow().find('div.app_modaldialogwindowtitle').hide();
					}
					if (APP.Utils.exists(msg)) {
						$j(modal_opts.element).jqmShow().find('pre.app_modaldialogwindowcontentmsg').hide();
						$j(modal_opts.element).jqmShow().find('div.app_modaldialogwindowcontent').html($j(msg).html());
					} else {
						$j(modal_opts.element).jqmShow().find('pre.app_modaldialogwindowcontentmsg').html(msg);
					}
					(modal_opts.msg_type) ? $j(modal_opts.element+' div.app_modaldialogwindowcontent').addClass(modal_opts.msg_type) : '';
					$j(modal_opts.element+' .modal_cancel_btn').hide();
					if (modal_opts.cancelbtn) {
						$j(modal_opts.element+' input.modal_cancel_btn').expire();
						$j(modal_opts.element+' input.modal_cancel_btn').livequery('click', function() {
							$j(modal_opts.element).jqmHide();
							return false;
						});
						$j(modal_opts.element).jqmShow().find('input.modal_cancel_btn').show();
					}
					if (modal_opts.closelink) {
						$j(modal_opts.element).jqmShow().find('a.modaldialogwindowclose').show();
					}
				}
				switch(type) {
					case 'confirm':
						if (modal_opts.usecustom && modal_opts.custom) {
							$j(modal_opts.element).jqmShow().find('input.modal_confirm_btn').show();
							$j(modal_opts.element).jqmShow().find('input.modal_ok_btn').hide();
							$j(modal_opts.element+' input.modal_confirm_no_btn').expire();
							$j(modal_opts.element+' input.modal_confirm_no_btn').livequery('click', function() {
								if (modal_opts.callback && typeof modal_opts.callback == 'function') {
									modal_opts.callback(this.name, modal_opts.callbackparams, settings);
						      modal_opts.callback = null;
								}
								$j(modal_opts.element).jqmHide();
							});
							$j(modal_opts.element+' input.modal_confirm_ok_btn').expire();
							$j(modal_opts.element+' input.modal_confirm_ok_btn').livequery('click', function() {
								if (modal_opts.callback && typeof modal_opts.callback == 'function') {
							    modal_opts.callback(this.name, modal_opts.callbackparams, settings);
						      modal_opts.callback = null;
						   	  $j(modal_opts.element).jqmHide();
								} else if (modal_opts.url && typeof modal_opts.url == 'string') {
					          window.location.href = modal_opts.url+'&confirm=1';
								}
							});
						} else {
							var res = window.confirm(msg);
							if (res) {
								return (modal_opts.url) ? window.location.href=modal_opts.url+'&confirm=1' : res;
							}
						}
						break;
					case 'message':
					case 'msg':
					default:
						if (modal_opts.usecustom && modal_opts.custom) {
							$j(modal_opts.element).jqmShow().find('input.modal_confirm_btn').hide();
							$j(modal_opts.element).jqmShow().find('input.modal_ok_btn').show();
							$j(modal_opts.element+' input.modal_ok_btn').expire();
							$j(modal_opts.element+' input.modal_ok_btn').livequery('click', function() {
								if (modal_opts.url && typeof modal_opts.url == 'string') {
					        		window.location.href = modal_opts.url;
								} else {
									$j(modal_opts.element).jqmHide();
								}
							});
						} else {
							alert(msg);
							(modal_opts.url) ? window.location.href = modal_opts.url : false;
						}
						break;
				}
			};
  		pub.block = function(settings) {
  		  block_opts = $j.extend({}, block_defaults, settings || {});
  			if (block_opts.element == 'full' || !block_opts.element) {
  			  block_opts.textcss.left = '45%';
					block_opts.textcss.border = 'none';
					$j.blockUI({message: block_opts.msg(), css: block_opts.textcss});
  			} else {
  			  $j(block_opts.element).unblock();
  			  $j(block_opts.element).block({message: block_opts.msg(), css: block_opts.textcss});
  			}
  		};
  		pub.blockbtn = function(sel) {
  		  $j(sel).attr('disabled', 'disabled');
			  $j(sel).addClass('disabled');
  		};
  		pub.unblockbtn = function(sel) {
  		  $j(sel).removeAttr('disabled');
			  $j(sel).removeClass('disabled');
  		};
			pub.uploadBlockUI = function(field) {
			  filename = ($j('#'+field).val()) ? $j('#'+field).val() : '';
			  APP.Utils.block({text: "File upload in progress, please wait ... "+filename, textcss: {width: '320px'}});
			};
  		pub.parseValue = function(value) {
  			var myval = pub.MyReplace(value, ",", ".");
  			var value = parseFloat(myval);
  			if (isNaN(value)) {
  				return '0.00';
  			} else {
  				return value.toFixed(2);
  			}
  		};
  		pub.MyReplace = function(sOrgVal,sSearchVal,sReplaceVal) {
			   var sVal;
			   try {
			      sVal = new String(sOrgVal);
			      if (sVal.length < 1) { return sVal; }
			      var sRegExp = eval("/" + sSearchVal + "/g");
			      sVal = sVal.replace(sRegExp,sReplaceVal);
			   }
			   catch (exception)  { alert('exception with replace'); }
			   return sVal.toString();
 			};
 			pub.dateInfo = function(date_calc_res) {
        return {
          years:  Math.floor((date_calc_res/31536000000)), 
          months: Math.floor(((date_calc_res % 31536000000)/2628000000)), 
          days:   Math.floor((((date_calc_res % 31536000000) % 2628000000)/86400000))}
 			};
 			
 			pub.datesBetween = function(start, end) {
 			  var dates = [];
 			  if (start != end && (typeof(start) == 'object' && typeof(end) == 'object')) {
 			    var dateinfo = APP.Utils.daysBetween(start, end);
 			    if (dateinfo > 1) {
 			      for (var i = 1; i < dateinfo; i++) {
 			        d = new Date(start.getFullYear(), start.getMonth(), start.getDate()-0+i);
              dates.push(d);
            }
          }
 			  }
  	    return dates;
 			};
 			pub.daysBetween = function(start, end) {
 			  if ((typeof(start) == 'object' && typeof(end) == 'object')) {
 			    var ONE_DAY = 1000 * 60 * 60 * 24;
          var difference_ms = Math.abs((start.getTime()) - (end.getTime()));
          return Math.round(difference_ms/ONE_DAY);
        }
 			};
 			pub.dateID = function(d, sep) {
 			  sep = (sep) ? sep : '-';
 			  return d.getFullYear()+sep+(((d.getMonth()+1) < 10) ? '0' : '')+(d.getMonth()+1)+sep+((d.getDate() < 10) ? '0' : '')+d.getDate();
 			};
 			pub.daysInMonth = function(year, month) {
 			  today = new Date();
 			  year = (year) ? year : today.getYear();
 			  month = (month) ? month : today.getMonth()+1;
 			  return new Date(year, month-0+1, 0).getDate();
 			};
			pub.getQueryParam = function(param, val) {
        param = param.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        var regexS = "[\\?&]"+param+"=([^&#]*)";
        var regex = new RegExp( regexS );
        var results = regex.exec(((val == undefined) ? window.location.href : val));
        if( results == null )
          return "";
        else
          return results[1];
      };
			pub.fieldSerializeArray = function(arr, allowempty) {
				var allowempty = (APP.Utils.isset(allowempty)) ? allowempty : true;
				var a = [];
				for (var i=0,max=arr.length;i<max;i++) {
					if (allowempty || (!allowempty && arr[i].value)) {
						 a.push({name: arr[i].name, value: arr[i].value});
					}
				}
			  return $j.param(a);
			};
			pub.isset = function(avar, val){
				res = (typeof(avar) != 'undefined');
				if (typeof(val) == 'undefined') {
					return res;
				} else {
					return (res) ? avar : val;
				}
			};
			pub.exists = function(el){
				return ($j(el).length > 0) ? true : false;
			};
			pub.clone = function(obj) {
   				if(obj == null || typeof(obj) != 'object') {
        			return obj;
				}
				var temp = new obj.constructor();
    			for(var key in obj) {
       				temp[key] = pub.clone(obj[key]);
				}
    		return temp;
			};
		  pub.propertyCount = function(obj) {
		    if (obj.__count__ === undefined) {
          obj.__count__ = function() { 
            var count = 0;
            for (k in obj) if (obj.hasOwnProperty(k)) count++;
            return count;
          };
          obj.__count__.toString = function() { return this(); };
        } else {
          return obj.__count__;
        }
		  };
		return pub;
	}().init();
	
	APP.register("Utils", APP.Utils, {version: "1.0", build: "1"});
	
	/**
	 * APP Ajax namespace
	 */
	APP.namespace('Ajax');
	
	APP.Ajax = function(){
		var pub = {};
		// private
		// setup inital state
		pub.init = function(){
			// global ajax callbacks
			$j().ajaxSend(function(elm, xhr, s) {
				if (s.type == "GET") return;
			    if (s.data && s.data.match(new RegExp("\\b" + window._auth_token_name + "="))) return;
			    if (s.data) {
			   		s.data = s.data + "&";
			    } else {
			      	s.data = "";
			      	xhr.setRequestHeader("Content-Type", s.contentType);
			    }
			    s.data += encodeURIComponent(window._auth_token_name) + "=" + encodeURIComponent(window._auth_token);
			});
			$j().ajaxStart(function() {
				//APP.Utils.pauseSessionTimer(null, true);
			});
			$j().ajaxComplete(function(elm, xhr, s) {
				//APP.Utils.updateSessionTimer(null, true);
			});
			$j().ajaxStop(function() {
				//APP.Utils.pauseSessionTimer(null, true);
			});
			$j().ajaxError(function(e, xhr, opt, err){
			  msg = "An error occured during the request.\nPlease try again or report this error to your application support staff."
        techmsg = '[AJAXREQUEST ERROR]: ['+opt.type+'] '+opt.url;
  			APP.Utils.log([techmsg, msg], xhr, null, 'error');
			});
			// create global ajaxabort callback
			jQuery.fn['ajaxAbort'] = function(f){
				return this.bind('ajaxAbort', f);
			};
			$j().ajaxAbort(function(e, xhr, opt, manager){
			});
			return pub;
		};
		// OLDER FUNCTIONALITY
		pub.load = function(settings) {
		  load_opts = $j.extend({},  {element: '', url: null, data: null, params: '', callback: null, useblockui: true}, settings || {});
			if (!load_opts.url || !load_opts.element) {
			  msg = "An error occured during the request.\nPlease try again or report this error to your application support staff."
        techmsg = '[AJAXREQUEST ERROR]: [LOAD - ELEMENT/URL ERROR] ';
			  APP.Utils.log([techmsg, msg], "\nurl:"+load_opts.url + ' element:' + load_opts.element, null, 'error');
				return false;
			} else {
    		if (!load_opts.data) {
    		  var url_prefix = ((load_opts.url.indexOf('/?') != -1) || load_opts.url.indexOf('?') != -1) ? '&' : '?';
    		  var random = url_prefix+'random=' + $j.uuid();
    		  if (typeof(load_opts.params) == 'object') {
    			  extra_params = $j.param(load_opts.params);
    			} else {
    				extra_params = load_opts.params;
    			}
    			load_opts.url += random+((extra_params) ? '&'+extra_params : '');
    		}
    		if (load_opts.useblockui) {
    			APP.Utils.block(load_opts);
    		}
    		$j(load_opts.element).load(load_opts.url, load_opts.data, load_opts.callback);
			}
		};
		pub.submit = function(settings) {
		  submit_opts = $j.extend({},  {  url: '', cache: false, type: 'POST', 
		                          form: null, 
		                          result_container: null, 
		                          flash_container: {target: 'body', type: 'prepend', closeable: true, title: null},
		                          handle_validation: true,
		                          error_container: {element: null, target: 'body', type: 'prepend', field_errors: false, field_prefix: ''},
		                          block: {element: '', text: ''},
		                          button: null, 
		                          callback: function(data, status, customstatus){}
		                        }, settings || {});
	    if (submit_opts.form) {
	      submit_opts.url = $j(submit_opts.form).attr('action');
	      submit_opts.data = $j(submit_opts.form).formSerialize();
	    }
	    if (submit_opts.error_container.element) {
		    $j(submit_opts.error_container.element+'_errorExplanation').remove();
		  }
		  if (APP.Utils.exists(submit_opts.flash_container.target)) {
		    $j(submit_opts.flash_container.target+' div.flash').remove();
		  }
      submit_opts.success = function (data, textStatus) {
        var custom_result = 'success';
        if (submit_opts.button) {
          APP.Utils.unblockbtn(submit_opts.button);
  		  }
        if (submit_opts.dataType == 'html' && submit_opts.result_container) {
          $j(submit_opts.result_container).html(data);
          if (APP.Utils.exists(submit_opts.result_container+' div.errorExplanation')) {
            custom_result = 'vfails';
          }
          if (submit_opts.flash_container && ($j(submit_opts.flash_container.target)[submit_opts.flash_container.type])) {
            flashes = $j(submit_opts.result_container+' div.flash').clone();
            $j(submit_opts.result_container+' div.flash').remove();
            $j(submit_opts.flash_container.target)[submit_opts.flash_container.type](flashes);
          }
          if (submit_opts.error_container && ($j(submit_opts.error_container.target)[submit_opts.error_container.type])) {
            errors = $j(submit_opts.result_container+' div.errorExplanation').clone();
            $j(submit_opts.result_container+' div.errorExplanation').remove();
            $j(submit_opts.error_container.target)[submit_opts.error_container.type](errors);
          }
        }
  		  if (submit_opts.dataType == 'json') {
  		    if (submit_opts.handle_validation == true && data.result == 'vfails' && submit_opts.error_container && data.errors && data.errors.length > 0) {
  		       custom_result = 'vfails';
  		       APP.Helpers.display_validation_errors(data.errors, submit_opts.error_container);
  		    }
  		    if (submit_opts.flash_container) {
  		       APP.Helpers.display_flashes(data.flashes, submit_opts.flash_container);
  		    }
  		  }
  		  if ((submit_opts.block && submit_opts.block.element) || submit_opts.result_container) {
  		    block_el = (submit_opts.block.element) ? submit_opts.block.element : submit_opts.result_container;
  		    $j(block_el).unblock();
  		  }
        if (submit_opts.callback && (typeof submit_opts.callback == 'function')) {
          return submit_opts.callback(data, textStatus, custom_result);
        }
      };
		  if (submit_opts.url) {
  		  if (submit_opts.button) {
  		    APP.Utils.blockbtn(submit_opts.button);
  		  }
  		  if ((submit_opts.block && submit_opts.block.element) || submit_opts.result_container) {
  		    block_el = (submit_opts.block.element) ? submit_opts.block.element : submit_opts.result_container;
  		    block_text = (submit_opts.block.text) ? submit_opts.block.text : 'Submitting data ...';
  		    APP.Utils.block({element: block_el, text: block_text, url: submit_opts.url});
  		  }
  		  $j.ajax(submit_opts);
	    } else {
	      return false;
	    }
		};
		return pub;
	}().init();
	
	APP.register("Ajax", APP.Ajax, {version: "1.0", build: "1"});
	
	/**
	 * APP Helpers namespace
	 */
	APP.namespace('Helpers');
	
	APP.Helpers = function() {
		var pub = {};
		// private
		var flash_defaults = {
			render_type: 'modal',
			target: '',
			type: '',
			msg_type: 'notice',
			closeable: true,
			css_class: '',
			prefix: null
		};
		// setup inital state
			pub.init = function () {
				return pub;
			};
		// public
		  pub.meta = function(obj, meta, settings) {
		    opts = $j.extend({}, {belongs_to: '', polymorphic: '', id: 'id'}, settings || {});
		    base_url = (APP.Utils.isset(meta.base_url)) ? meta.base_url : null;
		    id = (APP.Utils.isset(obj[opts.id])) ? obj[opts.id] : 'undefined';
		    return {
		      'index':    {url: base_url, method: 'GET'},
		      'create':   {url: base_url, method: 'POST'},
		      'new':      {url: base_url+'new', method: 'GET'},
		      'edit':     {url: base_url+id+'/edit', method: 'GET'},
		      'delete':   {url: base_url+id+'/delete', method: 'GET'},
		      'destroy':  {url: base_url+id+'/destroy', method: 'DELETE'},
		      'show':     {url: base_url+id, method: 'GET'},
		      'base':     {url: base_url+id+'/', method: 'GET'},
		      'update':   {url: base_url+id, method: 'PUT'}
		    };
		  };
		  pub.display_validation_errors = function(errors, settings) {
		    error_opts = $j.extend({}, {id: '', timeout: APP.Config.error_timeout}, settings || {});
		    if (APP.Utils.exists(error_opts.target)) {
    	    error_opts.id = (error_opts.element != '') ? error_opts.element.replace(/#/, '')+'_' : '';
    	    var errors_content = [];
    	    errors_content.push($j.create('h2', {}, ((errors.length == 1) ? errors.length+' need' : '1 error needs')+' to be fixed.'));
    	    var error_content = [];
    	    $j.each( errors, function(i, n){
    	      if (error_opts.field_errors) {
    	        pub.display_error_for(n[0], error_opts.field_prefix);
    	      }
    	      error_msg = n[0].humanize()+' '+n[1];
            error_content.push($j.create('li', {}, error_msg));
          });
    	    errors_content.push($j.create('ul', {}, error_content));
    	    if ($j(error_opts.target)[error_opts.type]) {
      	    $j(error_opts.target)[error_opts.type]($j.create('div', {id: error_opts.id+'errorExplanation', 'class': 'errorExplanation'}, errors_content));
      			if (error_opts.timeout > 0) { setTimeout("$j('#"+error_opts.id+"errorExplanation').fadeOut('slow');", (error_opts.timeout*1000)); }
    		  }
		    }
		  };
		  pub.display_flash = function(msg, settings) {
				flash_opts = $j.extend({timeout: APP.Config.flash_timeout}, flash_defaults, settings || {});
				if (flash_opts.render_type == 'modal') {
					APP.Utils.modal('message', msg, {title: 'Message: '+flash_opts.msg_type, msg_type: flash_opts.msg_type});
				} else if (flash_opts.render_type == 'element') {
				  uuid = $j.uuid();
				  var flash = $j.create('div', {id: 'flash_'+uuid, 'class': 'flash flash_'+flash_opts.msg_type},
					  [$j.create('p', {'class': 'message'}, [flash_opts.prefix,' ',msg])]
					);
					return flash;
				} else if (flash_opts.render_type == 'target' && APP.Utils.exists(flash_opts.target)) {
				  closelink = (flash_opts.closeable) ? $j.create('a', {href: '#', 'class': 'close'}, 'X') : null;
					uuid = $j.uuid();
					var flash = $j.create('div', {id: 'flash_'+uuid, 'class': 'flash flash_'+flash_opts.msg_type},
					  [closelink, $j.create('p', {'class': 'message'}, msg)]
					);
					if ($j(flash_opts.target)[flash_opts.type]) {
						$j(flash_opts.target)[flash_opts.type](flash);
						if (flash_opts.timeout) { setTimeout("$j('#flash_"+uuid+"').fadeOut('slow');", flash_opts.timeout*1000); }
					}
				}
			};
		  pub.display_flashes = function(flashes, settings) {
		    flashes_count = APP.Utils.propertyCount(flashes);
		    if (flashes_count > 1) {
		      flashes_opts = $j.extend({timeout: APP.Config.flash_timeout}, flash_defaults, settings || {});
		      var flashes_content = [];
		      title = (flashes_opts.title) ? flashes_content.push($j.create('p', {'class': 'title'}, flashes_opts.title)) : null;
		      $j.each( flashes, function(i, n){
  		      prefix = $j.create('span', {'class': 'flashtype flash_'+i}, '['+i+']');
  		      flashes_content.push(pub.display_flash(n, {render_type: 'element', msg_type: i, prefix: prefix}));
          });
          closelink = (flashes_opts.closeable) ? $j.create('a', {href: '#', 'class': 'close'}, 'X') : null;
		      uuid = $j.uuid();
		      var flashes_container = $j.create('div', {id: 'flashes_'+uuid, 'class': 'flashes'},
					  [closelink, $j.create('div', {'class': 'messages'}, flashes_content)]
					);
          if ($j(flashes_opts.target)[flashes_opts.type]) {
						$j(flashes_opts.target)[flashes_opts.type](flashes_container);
						if (flashes_opts.timeout) { setTimeout("$j('#flashes_"+uuid+"').fadeOut('slow');", flashes_opts.timeout*1000); }
					}
		    } else {
		      $j.each( flashes, function(i, n){
  		      pub.display_flash(n, $j.extend(settings, {msg_type: i, render_type: 'target'}));
          });
		    }
		  };
		  pub.display_error_for = function(field, prefix) {
		    fieldname = (prefix) ? prefix+'_'+field : field;
		    //$j('#'+fieldname).wrap('<div class="fieldWithErrors"></div>');
		    $j('#'+fieldname).css('background', '#f2afaf');
		  };
			return pub;
	}().init();
	
	APP.register("Helpers", APP.Helpers, {version: "1.0", build: "1"});
	
	/**
	 * Application namespace
	 */
	APP.namespace('modules');

	/**
	 * Global initialization
	 */
	
	if (APP.env == 'debug') { APP.Utils.initDebugger(); }
  // Type handling
  	// formats a textbox of class intvalue to correct float representation
  	$j('.floatvalue').expire();
  	$j('.floatvalue').livequery('change blur', function(event) {
  		var value = APP.Utils.parseValue($j(this).val());
  		if ($j(this).is('.percentage')) {
  			if (value > 100) {
  				value = 100.00;
  			}
  		}
  		if ($j(this).is('.percentage2')) {
  			if (value > 1000) {
  				value = 999.00;
  			}
  		}
  		$j(this).val(value);
  		if ($j(this).is('.callback')) {
  			$j(document).trigger(this.id, [{id: this.id, value: value}]);
  		}
  	});
  	// formats a textbox of class intvalue to correct integer representation
  	$j('.intvalue').expire();
  	$j('.intvalue').livequery('change blur', function() {
  		var value = parseInt($j(this).val());
  		if (isNaN(value)) {
  			if ($j(this).is('.defaultval')) {
  				$j(this).val(0);
  			} else if ($j(this).is('.defaultval1')) {
  			  $j(this).val(1);
  			} else {
  				$j(this).val('');
  			}
  		} else {
  			$j(this).val(value);
  		}
  	});
  	// formats a textbox of class timevalue to correct time representation
  	$j('.timevalue').expire();
  	$j('.timevalue').livequery('change blur', function() {
  		var info = $j(this).val().split(':');
  		if (info.length == 2) {
  			val1 = (isNaN(parseInt(info[0]))) ? 0 : parseInt(info[0]);
  			val2 = (isNaN(parseInt(info[1]))) ? 0 : parseInt(info[1]);
  			if (val2 < 10) {
  				val2 = '0'+val2;
  			} else if (val2 >= 60) {
  				val1++;
  				val2 = '00';
  			}
  			$j(this).val(val1+':'+val2);
  		} else {
  			var value = APP.Utils.parseValue($j(this).val());
  			var info = value.split('.');
  			if (info.length == 2 && value > 0) {
  				val1 = (isNaN(parseInt(info[0]))) ? 0 : parseInt(info[0]);
  				val2 = (isNaN(parseInt(info[1]))) ? 0 : (parseInt(info[1]) * 6);
  				if (val2 < 10) {
  					val2 = '0'+val2;
  				} else if (val2 > 599) {
  					val1++;
  					val2 = '00';
  				} else {
  					val2 = parseInt(val2 / 10);
  					if (val2 > 59) {
  						val1++;
  						val2 = '00';
  					}
  				}
  				$j(this).val(val1+':'+val2);
  			} else {
  				$j(this).val('0:00');
  			}
  		}
  		if ($j(this).is('.callback')) {
  			$j(document).trigger(this.id, [{id: this.id, value: value}]);
  		}
  	});
  	// sets a default value for textbox
  	$j('.defaultvalue').expire();
  	$j('.defaultvalue').livequery('change blur', function() {
  		if ($j(this).attr('title') != $j(this).val() && $j(this).val() != '') {
  			$j(this).removeClass('default');
  		} else {
  			$j(this).addClass('default');
  			$j(this).val($j(this).attr('title'));
  		}
  	});
  	$j('.defaultvalue').livequery('focus', function() {
  		$j(this).removeClass('default');
  		if ($j(this).val() == $j(this).attr('title')) {
  			$j(this).val('');
  		}
  	}),
	
	// Misc
	  $j('input.submit').removeAttr('disabled');
	  $j('input.submit').click(function() {
	    APP.Utils.blockbtn(this);
  	  //$j(this).parents("form")[0].submit();
  	  return true;
  	});
	
	// Print
		$j('#print a').click(function () { 
	      window.print();
	    });
	// Datagrid rowclicks
		$j('table.datagrid td').expire();
		$j('table.datagrid td').livequery('click', APP.Utils.onRowClick);
  // Ajax paging links
		$j('div.pagination a').expire();
		$j('div.pagination a').livequery('click', function(){
		  pagingel = $j(this).parent().parent();
		  if (pagingel.is('.ajaxable')) {
		    var subject_table = pagingel.parent().attr('id');
		    var page = ($j(this).attr('class') == '') ? parseInt($j(this).html()) : null;
		    var data = {url: $j(this).attr('href'), page: page}
		    $j(document).trigger('process_'+subject_table+'_paging', data);
		    return false;
		  } else {
		    return true;
		  }
		});
	// Datagrid hovers
		$j('table.datagrid tr.row-even, table.datagrid tr.row-odd, table.filtergrid tr.row-even, table.filtergrid tr.row-odd').expire();
		$j('table.datagrid tr.row-even, table.datagrid tr.row-odd, table.filtergrid tr.row-even, table.filtergrid tr.row-odd').livequery(
			function(){
				$j(this).hover(function() {
					$j(this).addClass('hover');
				}, function() {
					$j(this).removeClass('hover');
				});
			}, 
			function() {
				$j(this).unbind('mouseover').unbind('mouseout');
			}
		);
	// Datagrid actions
		$j('table.datagrid a.delete_link').livequery('click', function(){
			var custommodal = ($j(this).is('.normal')) ? true : false;
			var link = this;
			var conf = APP.Utils.modal('confirm', 'Are you sure want to delete this \n' + $j(this).attr('title')+' ?',{
				callback: function(res) {
					if (res == 'yes') {
						var f = document.createElement('form'); 
						f.style.display = 'none'; 
						$j(link).parent().append(f);
						f.method = 'POST'; 
  					f.action = $j(link).attr('href').replace(/\/delete/,"");
						var m = document.createElement('input'); 
						m.setAttribute('type', 'hidden'); 
						m.setAttribute('name', '_method'); 
						m.setAttribute('value', 'delete'); 
						f.appendChild(m);
						var s = document.createElement('input'); 
						s.setAttribute('type', 'hidden'); 
						s.setAttribute('name', window._auth_token_name); 
						s.setAttribute('value', window._auth_token); 
						f.appendChild(s);
						f.submit();
					}
				}
			});
			return false;
		});
		$j('table.datagrid a.destroy_link').livequery('click', function(){
			var custommodal = ($j(this).is('.normal')) ? true : false;
			var link = this;
			var conf = APP.Utils.modal('confirm', 'Are you sure want to delete this \n' + $j(this).attr('title')+' ?',{
				callback: function(res) {
					if (res == 'yes') {
						var f = document.createElement('form'); 
						f.style.display = 'none'; 
						$j(link).parent().append(f);
						f.method = 'POST'; 
  					f.action = $j(link).attr('href');
						var m = document.createElement('input'); 
						m.setAttribute('type', 'hidden'); 
						m.setAttribute('name', '_method'); 
						m.setAttribute('value', 'delete'); 
						f.appendChild(m);
						var s = document.createElement('input'); 
						s.setAttribute('type', 'hidden'); 
						s.setAttribute('name', window._auth_token_name); 
						s.setAttribute('value', window._auth_token); 
						f.appendChild(s);
						f.submit();
					}
				}
			});
			return false;
		});
	// Search
		$j('.actlinksearch').livequery('click', function(){
			$j('.search_form').fadeIn("fast");
			return false;
		});
		$j('.search_close').livequery('click', function(){
			$j('.search_flash').fadeOut("fast");
			$j('.search_form').fadeOut("fast");
			return false;
		});
		$j('.search_info').livequery('click', function(){
			APP.Utils.modal('message', '#app_search_info', {element: '#searchinfo_modal', title: 'Search help'});
			return false;
		});
		$j('#form_search').submit(function(){
			pars = APP.Utils.fieldSerializeArray($j(this).formToArray(), false);
			if (pars) {
				window.location.href = $j(this).attr('action') + '?' + pars;
			} else {
			  $j('#form_search input:submit').removeAttr('disabled');
			  $j('#form_search input:submit').removeClass('disabled');
				APP.Helpers.display_flash('No search criteria defined, search cannot be performed.', {render_type: 'modal', type: 'before', msg_type: 'notice', target: '.search_form', ccs_class: 'search_flash'});
			}
			return false;
		});
		$j('.clear_search_btn').livequery('click', function(){
			var subject = $j(this).attr('id').replace(/_clear_search_btn/,"");
			window.location.href = '/'+subject;
		});
	// Actionlinks
		$j('div.flash a.close, div.flashes a.close').livequery('click', function(){
			$j($j(this).parent()).fadeOut("slow");
			return false;
		});
});
