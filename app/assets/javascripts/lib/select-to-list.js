(function ($) {

$.selectToList = function( selectObject, options ) {
  var DEFAULTS = {
    objectName: 'item'
  };

  var settings = $.extend({}, DEFAULTS, options || {});

  var tagList = $( '<ul></ul>' ).addClass('tag-list');
  
  // Initialize a list of all the tags
  var tags = {};
  selectObject.find( 'option' ).each( function() {
    tags[ $(this).val() ] = $(this).text();
  });
  
  // Function to add an item to the tag list
  function addItem( id, name, fade ) {
    
    // Add the item only if it exists in the tags collection
    if ( delete tags[ id ]) {
      var item = $( '<li></li>' );

      item.text( name );
      item.data( 'id', id );
      item.data( 'name', name );

      item.append('<a href="#" class="remove-link"></a>'); 
      item.appendTo( tagList );

      if (fade) {
        item.hide().fadeIn();
      }

      selectObject.find( 'option[value=' + id + ']' ).prop( 'selected', true );
      selectObject.trigger('itemAdded', [ id, name ]);
    }
  }
  
  // Handling the remove link for each tag list item
  tagList.on( 'click', '.remove-link', function(e) {
    e.preventDefault();

    var li = $(this).parent( 'li' );
    var id = li.data('id');
    var name = li.data('name');

    selectObject.find( 'option[value=' + id + ']' ).prop( 'selected', false );
    li.fadeOut('fast', function() {
      li.remove();
    });

    tags[ id ] = name;

    selectObject.trigger('itemRemoved', [ id, name ]);
  });


  // Initialization
  selectObject.hide();
  tagList.insertBefore( selectObject )

  // Add each selected item to the list
  selectObject.find( 'option:selected' ).each( function(){
    addItem( $(this).val(), $(this).text() );
  });

  // Create an add link
  var addLink = $( '<a href="#" class="add-link">Add ' + settings.objectName + '</a>' );
  addLink.insertAfter( tagList );

  // Initialize a list to pick tags
  var pickTagList = $( '<div></div>' ).insertAfter( addLink ).hide();
  pickTagList.filterableList({
    positionBelow: addLink
  });

  pickTagList.on('itemSelected', function(e, id, name){ 
    addItem( id, name, true );
  });
  
  // Handle adding tags
  addLink.on('click', function(e) {
    e.preventDefault();

    pickTagList.filterableList('toggleMenu', tags);
  });
}

}(jQuery));