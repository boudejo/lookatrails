Person = {};

People = function() {
	// internal shorthand
	var pub = {};
	// private
	  var info = {};
	// setup inital state
	pub.init = function () {
	  pub.meta.base_url = '';
		return pub;
	};
	// public vars
	pub.meta = {};
	pub.identity = null;
	// public methods
	pub.setup = function(instance) {
	  instance.subject = 'person';
	  instance.meta = APP.Helpers.meta(instance, pub.meta, {polymorphic: pub.identity});
	  Person = instance;
	};
	pub.load = function(settings) {
	  APP.Ajax.load(settings);
	};
	pub.update = function(frm) {
	  APP.Ajax.submit({
	    form:               frm,
	    button:             '#person_submit',
	    result_container:   '#'+pub.identity.container,
	    block:              {element: '#'+pub.identity.container, text: 'Submitting '+pub.identity.subject_text+' data ...'},
	    flash_container:    {target: '.tabcontainer', type: 'prepend'},
	    error_container:    {element: null},
	    dataType:           'html',
	    callback: function(data, status, customstatus) {
	      if (customstatus == 'success') {
	        $j('#fullcode_postal').html($j('#person_address_address_postal').val());
	      }
	    }
	  });
	  return false;
	};
	return pub;
}().init();