Opportunity = {};

Opportunities = function() {
	// internal shorthand
	var pub = {};
	// setup inital state
	pub.init = function () {
	  pub.meta.base_url = '/crm/opportunities/';
	  using.register("documents", "/javascripts/views/documents.js");
	  using.register("resources", "/javascripts/views/resources.js");
		return pub;
	};
	// public vars
	pub.meta = {};
	pub.tabs = {};
	// public methods
	pub.setup = function(instance, tab_data) {
	  instance.subject = 'opportunity';
	  instance.meta = APP.Helpers.meta(instance, pub.meta);
	  Opportunity = instance;
	  pub.tabs = tab_data;
	};
	pub.handleTab = function(tab, readonly, editable) {
	  tab = tab.replace(/#/,"");
	  tab_text = $j('#'+tab+'_tab_link').html();
	  tab_data = pub.tabs[tab]
	  switch(tab) {
      case 'files':
        using("documents", function(){
    	    Documents.setup(Opportunity, readonly, editable);
    	  });
        break;
      case 'resources':
        using("resources", function(){
          Resources.setResourceType(Opportunity);
    	    Resources.load_init(tab_data);
        });
        break;
      default:
        break;
    }
	};
	return pub;
}().init();