Communications = function() {
	// internal shorthand
	var pub = {};
	// private
		var subject = '';
	// setup inital state
	pub.init = function () {
		return pub;
	};
	// public
	pub.setSubject = function(thesubject) {
	  subject = thesubject;
	};
	pub.to_s = function() {
	  return subject;
	};
	return pub;
}().init();

