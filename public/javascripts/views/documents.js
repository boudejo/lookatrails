Documents = function() {
	// internal shorthand
	var pub = {};
	// private
		var subjects = {};
	// setup inital state
	pub.init = function () {
		return pub;
	};
	// public vars
	pub.documentable = null;
	// public methods
	pub.setup = function(obj, readonly, editable) {
	  pub.documentable = obj;
    if (readonly || editable) {
      Documents.setUploadLoaded()
    }
    if (!Documents.isUploadLoaded()) {
      Documents.loadUploadDocument(false);
    }
    Documents.loadDocuments(false);
	};
	pub.isUploadLoaded = function() {
	  return (subjects[pub.documentable.subject] && subjects[pub.documentable.subject] === true) ? true : false;
	};
	pub.setUploadLoaded = function() {
	  subjects[pub.documentable.subject] = true;
	  pub.loadDocumentHandlers();
	};
	pub.loadUploadDocument = function(useblockui) {
    APP.Ajax.load({
  		element: 	  '#'+pub.documentable.subject+'_document_upload',
  		url: 		    pub.documentable.meta.show.url+'/documents/new',
  		useblockui:	useblockui
  	});
  	pub.setUploadLoaded();
  };
  pub.loadDocuments = function(useblockui, url) {
    APP.Ajax.load({
  		element: 	  '#'+pub.documentable.subject+'_documents',
  		url: 		    (typeof(url) != 'undefined') ? url : pub.documentable.meta.show.url+'/documents/',
  		useblockui:	useblockui,
  		callback: function(response, status, xhr) {
  		  $j(document).unbind(pub.documentable.subject+'_documents_grid_rowclick');
  		  $j(document).bind(pub.documentable.subject+'_documents_grid_rowclick', function(event, data){
          if (!$j('#'+data.parsed).is('.not_exists')) {
            window.location.href = $j('#download_'+data.parsed).attr('href'); 
          }
          return false;
        });
        $j('#'+pub.documentable.subject+'_documents div.paging a').click(function(){
          Documents.loadDocuments(true, $j(this).attr('href'));
          return false;
        });
  		}
  	});
  };
  pub.loadDocumentHandlers = function() {
    subj = pub.documentable.subject;
    $j('#show_'+subj+'_document_upload').expire('click');
  	$j('#show_'+subj+'_document_upload').livequery('click', function(){
  	  if ($j('#'+subj+'_document_upload').is(':visible')) {
  	    $j('#'+subj+'_document_upload').hide('fast');
  	  } else {
  	    $j('#'+subj+'_document_upload').show('fast');
  	  }
  	  return false;
  	});
  	$j('#refresh_'+subj+'_documents').expire('click');
  	$j('#refresh_'+subj+'_documents').livequery('click', function(){
  		Documents.loadDocuments(true);
  		return false;
  	});
  };
	return pub;
}().init();

