/*
**  jquery.debug.js -- jQuery plugin for debugging
**  Copyright (c) 2007 Ralf S. Engelschall <rse@engelschall.com> 
**  Licensed under GPL <http://www.gnu.org/licenses/gpl.txt>
**
**  $LastChangedDate$
**  $LastChangedRevision$
*/
(function($) {
    /* jQuery class extension methods */
    $.extend({
        /* method for logging an object or message */
        log: function (msg, data, cat) {
			var msg = (typeof msg != "undefined") ? msg : '';
			var cat = (typeof cat != "undefined") ? cat : 'debug';
			var data = (typeof data != "undefined") ? data : '';
            if (window._debug == true && window.console[cat] && typeof window.console[cat] == 'function') {
				window.console[cat](msg, data);
			}
        }
    });

    /* jQuery object extension methods */
    $.fn.extend({
        /* method for logging all jQuery items */
        log: function (msg, cat) {
            if (window._debug == true) {
                return this.each(function () {
                    $.log(msg, this, cat);
                });
            }
        }
    });
})(jQuery);