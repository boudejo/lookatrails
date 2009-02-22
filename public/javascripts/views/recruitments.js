Recruitment = {};

Recruitments = function() {
	// internal shorthand
	var pub = {};
	// private
		// ...
	// setup inital state
	pub.init = function () {
	  pub.meta.base_url = '/pis/hr/recruitments/';
	  using.register("documents", "/javascripts/views/documents.js");
		return pub;
	};
	// public vars
	pub.meta = {};
	// public methods
	pub.setup = function(instance) {
	  instance.subject = 'recruitment';
	  instance.meta = APP.Helpers.meta(instance, pub.meta);
	  Recruitment = instance;
	};
	pub.handleTab = function(tab, readonly, editable) {
	  tab = tab.replace(/#/,"");
	  tab_text = $j('#'+tab+'_tab_link').html();
	  switch(tab) {
      case 'files':
        using("documents", function(){
    	    Documents.setup(Recruitment, readonly, editable);
    	  });
        break;    
      default:
        break;
    }
	};
	return pub;
}().init();