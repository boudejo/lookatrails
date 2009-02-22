/*
 * jQuery Timer PLugin
 *
 * v0.1.5 (7 november 2007)
 *
 * Copyright (c) 2007 LisaraÌÇl (http://www.lisaserver.be)
 * Licensed under the GPL license.
 *
 */
(function() {
	jQuery.extend(jQuery, {
		timer : function(settings, execFunc) {
			jQuery.setTimer(settings, execFunc, true);
		},
		setTimer : function(settings, execFunc, run) {
 			settings = jQuery.extend({
				name: "timer"+(jQuery.timers.length+1),
				interval: 1,
				end: false
			}, settings);
			var t_end = "unlimited";
			var t_name = settings.name;
			if( !isNaN( parseInt(settings.end, 10) ) ) t_end = parseInt(settings.end, 10);
			jQuery.timers[settings.name] = {
				cycle : 0,
				interval: settings.interval,
			    end : t_end,
			    state: "stopped",
			    timer: "",
			    func: execFunc
			};
			if( run ) {
				jQuery.runTimer( settings.name );
			}
 		},
 		runTimer : function(name) {
 			jQuery.timers[name].timer = window.setInterval(function() {
				jQuery.timers[name].func();
			    jQuery.timers[name].cycle++;
			    if( jQuery.timers[name].end != "unlimited" && jQuery.timers[name].cycle >= jQuery.timers[name].end ) {
			    	jQuery.stopTimer(name);
			    }
			}, jQuery.timers[name].interval * 1000);
			jQuery.timers[name].state = "run";
 		},
 		stopTimer : function(name) {
  			clearInterval( jQuery.timers[name].timer );
  			jQuery.timers[name].state = "stopped";
  		}
	});
})();