(function ($) {

DEFAULTS = {
  containerClass: 'filterable-list',
  positionBelow: null
};

// Exposed methods
var methods = {
  init: function( options ) {
    var settings = $.extend({}, DEFAULTS, options || {});

    return this.each(function () {
      $(this).data( "filterableListObject", new $.FilterableList( $(this), settings ));
    });
  },
  start: function( data ) {
    this.data( "filterableListObject" ).start( data );
    return this;
  },
  toggleMenu: function( data ) {
    this.data( "filterableListObject" ).toggleMenu( data );
    return this;
  }
}

// Expose the .filterableList function to jQuery as a plugin
$.fn.filterableList = function (method) {
  if( methods[method] ) {
    return methods[method].apply( this, Array.prototype.slice.call(arguments, 1) );
  } else {
    return methods.init.apply( this, arguments );
  }
};

// List class
$.FilterableList = function( container, settings ) {

  // Set class
  container.addClass( settings.containerClass );
  container.hide();
  var listShown = false;

  // Initialize elements
  var textbox = $('<input />').appendTo(container);
  var itemList = $('<ul></ul>').appendTo(container);

  // Case insensitive contains matcher
  $.expr[':'].contains_ci = function(a,i,m){
      return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase())>=0;
  };

  // Setup filtering
  textbox.on( 'keyup', function() {
    textbox.trigger( 'change' )
  });

  textbox.on( 'change', function() {
    var filter = textbox.val();
    
    if ( filter ) {

      hideItems( itemList.find( 'li:not(:contains_ci(' + filter + '))' ));
      showItems( itemList.find( 'li:contains_ci(' + filter + ')' ).show());
    } 
    else {

      showItems( itemList.find('li'));
    }
  });

  // Capture any clicks within the container and stop propogation
  container.on( 'click', function(e) {
    e.stopPropagation();
  });

  // Public functions
  this.start = function( data ) {
    if (listShown) {
      $(document).off('click', hideList);
    }
    startList( data )
  };

  this.toggleMenu = function( data ){
    if (!listShown) {
      startList(data);
    }
  }

  // Private functions
  function startList( data ) {
    clearList();
    buildList( data );
    textbox.val("").focus();
    showList();
    repositionList();
  }

  function clearList() {
    itemList.empty();
  }

  function buildList( items ) {
    $.each( items, function( id, name ) {
      var li = $('<li></li>');
      
      li.attr( 'data-id', id )
        .attr( 'data-name', name )
        .text( name )
        .appendTo(itemList);

      li.on( 'click', function() {
        container.trigger( 'itemSelected', [ id, name ] );
        hideList();
      });
    });
  }

  function showList() {
    container.fadeIn();
    listShown = true;

    setTimeout( function() {
      // Hide the list if the user clicks outside it
      $(document).one('click', hideList);
    }, 200);
  }

  function hideList() {
    container.fadeOut('fast');
    
    $(document).off('click', hideList);
    listShown = false;
  }

  function showItems( items ) {
    items.slideDown('fast');
  }

  function hideItems( items ) {
    items.slideUp('fast');
  }

  function repositionList() {
    if ( settings.positionBelow ) {
      var pos = settings.positionBelow.position();
      pos.top += settings.positionBelow.outerHeight();
      container.position( pos );
    }
  }
};

}(jQuery));