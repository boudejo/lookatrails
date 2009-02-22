Car = {};

Cars = function() {
	// internal shorthand
	var pub = {};
	// setup inital state
	pub.init = function () {
	  pub.meta.base_url = '/crm/cars/';
		return pub;
	};
	// public vars
	pub.meta = {};
	// public methods
	pub.setup = function(instance) {
	  instance.subject = 'car';
	  instance.meta = APP.Helpers.meta(instance, pub.meta);
	  Car = instance;
	};
	return pub;
}().init();

