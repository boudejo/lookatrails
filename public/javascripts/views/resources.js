Resource = {};

Resources = function() {
	// internal shorthand
	var pub = {};
	// private
	  var new_loaded = false
	// setup inital state
	pub.init = function () {
		return pub;
	};
	// public vars
	pub.meta = {};
	pub.resourceable = null;
	// public methods
	pub.setup = function(instance) {
	  instance.subject = 'resource';
	  instance.meta = APP.Helpers.meta(instance, pub.meta);
	  Resource = instance;
	};
	pub.setResourceType = function(instance) {
	  pub.resourceable = instance;
	};
	pub.load_init = function(opts) {
	  APP.Utils.blockbtn('#show_new_'+pub.resourceable.subject+'_resource');
	  if (!new_loaded) { pub.load_new(opts.new_url); }
	  pub.loadList(opts.collection_url);
	};
  pub.load_new = function(url, useblockui) {
    subj = pub.resourceable.subject;
    APP.Ajax.load({
  		element: 	  '#new_'+subj+'_resource',
  		url: 		    url,
  		useblockui:	useblockui,
  		callback:   function() {
  		  new_loaded = true;
  		  $j('#show_new_'+subj+'_resource').expire('click');
      	$j('#show_new_'+subj+'_resource').livequery('click', function(){
      	  if ($j('#new_'+subj+'_resource').is(':visible')) {
      	    $j('#new_'+subj+'_resource').hide('fast');
      	  } else {
      	    $j('#new_'+subj+'_resource').show('fast');
      	  }
      	  return false;
      	});
  		}
  	});
  };
  pub.loadList = function(url) {
    subj = pub.resourceable.subject;
  	APP.Ajax.load({
  		element: 	   '#'+subj+'_resources',
  		url: 		    url,
  		text:       'Resources are loading ...',
  		callback:   function(response, status, xhr) {
      	// Grid binding
      	$j(document).unbind('resources_grid_rowclick');
      	$j(document).bind('resources_grid_rowclick', function(e, data){
      	  //console.log('clicked');
      	  //console.log(data);
      	  return false;
      	});
      	// Refresh button
		    $j('#refresh_'+subj+'_resources').expire('click');
      	$j('#refresh_'+subj+'_resources').livequery('click', function(){
      		Resources.loadList(url);
      		return false;
      	});
      	// Paging
      	$j('#'+subj+'_resources div.paging a').expire('click');
      	$j('#'+subj+'_resources div.paging a').livequery('click', function(){
          Resources.loadList($j(this).attr('href'));
          return false;
        });
  		}
  	});
  };
  pub.create = function(frm) {
    subj = pub.resourceable.subject;
	  APP.Ajax.submit({
      form:               frm,
	    button:             '#resource_submit_new',
	    result_container:   '#new_'+subj+'_resource',
	    block:              {element: '#new_'+subj+'_resource', text: 'Submitting resource data ...'},
	    flash_container:    {target: '.tabcontainer', type: 'prepend'},
	    error_container:    {element: null},
	    dataType:           'html',
	    callback:           function(data, status) {
	      //$j(frm).clearForm();
	      Resources.loadList(Opportunity.meta.base.url+'resources')
	    }
	  });
    return false;
  },
  pub.clearForm = function(frm) {
    $j(frm).resetForm();
    $j('#resource_employee_id').filterReset();
  };
  pub.update = function() {
    //console.log('update');
    return false;
  }
	return pub;
}().init();