Employee = {};

Employees = function() {
	// internal shorthand
	var pub = {};
	// setup inital state
	pub.init = function () {
	  pub.meta.base_url = '/pis/hr/employees/';
	  using.register("documents",  "/javascripts/views/documents.js");
	  using.register("people",     "/javascripts/views/people.js");
	  using.register("salaries",   "/javascripts/views/salaries.js");
	  using.register("timesheets", "/javascripts/views/timesheets.js");
		return pub;
	};
	// public vars
	pub.meta = {};
	pub.tabs = {};
	// public methods
	pub.setup = function(instance, tab_data) {
	  instance.subject = 'employee';
	  instance.meta = APP.Helpers.meta(instance, pub.meta);
	  Employee = instance;
	  pub.tabs = tab_data;
	};
	pub.handleTab = function(tab, readonly, editable) {
	  tab = tab.replace(/#/,"");
	  tab_text = $j('#'+tab+'_tab_link').html();
	  tab_data = pub.tabs[tab]
	  switch(tab) {
      case 'files':
        using("documents", function(){
    	    Documents.setup(Employee, readonly, editable);
    	  });
        break;    
      case 'personal':
        using("people", function(){
          People.identity = {subject: 'employee', container: 'employee_'+tab, subject_text: 'personal'};
          People.load({
        		element: 	  '#employee_'+tab,
        		url: 		    (tab_data) ? tab_data.url : null,
        		text:       tab_text+' is loading ...'
        	});
        });
        break;
      case 'cost':
        using("salaries", function(){
          Salaries.employee = Employee;
          Salaries.load({url: ((tab_data) ? tab_data.salary_url : null)});
  	      Salaries.loadHistory({url: ((tab_data) ? tab_data.collection_url : null)});
  	    });
        break;
      case 'timesheet':
        using("timesheets", function(){
          Timesheets.employee = Employee;
          Timesheets.loadHistory({url: ((tab_data) ? tab_data.collection_url : null)}, {url: ((tab_data) ? tab_data.url : null)});
        });
        break;
      default:
        break;
    }
	};
	return pub;
}().init();