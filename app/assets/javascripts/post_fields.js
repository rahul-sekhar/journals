$(document).ready(function() {

if ( $('body')[0].id != 'post_fields' ) {
  return;
}

// Convert the multi selects for teachers and students to lists with filtering
$.selectToList( $( '#post_teacher_ids' ), {
  objectName: 'teacher'
});

var studentTagSelect = $( '#post_student_ids' )
$.selectToList( studentTagSelect, {
  objectName: 'student'
});


// Handle student observations
var obsFieldset = $( 'fieldset.student-observations' )
if (obsFieldset.length) {

  var obsEditor = $( '<textarea></textarea>' )
    .attr( 'id', 'observation-editor' );

  var buttonList = $( '<ul></ul>' )
    .attr( 'id', 'observation-buttons' );

  var obsIframe;

  // Functions for student observations
  function addButton( id, name ) {
    var li = $( '<li data-id=' + id + '></li>' );
    li.append( '<a href="#">' + name + '</a>' );
    li.appendTo(buttonList);
  }

  function removeButton( id ) {
    buttonList.find( 'li[data-id=' + id + ']' ).remove();
  }

  function checkHeight() {
    if (( buttonList.outerHeight() + 10) > obsIframe.outerHeight()) {
      obsIframe.height(buttonList.outerHeight() + 10);
    }
  }

  function currentId() {
    var selectedButton = buttonList.find('li.selected:first');
    return selectedButton.data('id') || 0;
  }

  function setSelected( id ) {
    var current = currentId();
    if ( current == id ) return;
    
    buttonList.find( 'li' ).removeClass( 'selected' );
    buttonList.find( 'li[data-id=' + id + ']').addClass( 'selected' );

    if ( current > 0 ) {
      saveContent(current);
    }

    loadContent(id);
  }

  function saveContent(id) {
    var content = obsEditor.html();
    var field = obsFieldset.find( '.fields[data-id=' + id + '] textarea');
    field.val( content );
  }

  function loadContent(id) {
    var field = obsFieldset.find( '.fields[data-id=' + id + '] textarea');
    obsEditor.html( field.val() );
  }

  function selectFirst() {
    var firstStudent = buttonList.find('li:first');
    setSelected( firstStudent.data('id') )
  }

  function findLargestIndex() {
    var index = 0;
    obsFieldset.find('.fields').each( function() {
      var this_index = $(this).data( 'index' );
      if ( this_index > index ) {
        index = this_index
      }
    });
    return index;
  }

  function constructFields( id, name ) {
    var index = findLargestIndex() + 1;
    var div = $('<div></div>')
      .addClass('fields')
      .attr('data-id', id)
      .attr('data-name', name)
      .attr('data-index', index)
      .appendTo(obsFieldset)
      .hide();

    div.append('<input name="post[student_observations_attributes][' + index + '][student_id]" type="hidden" value="' + id +'"/>');
    div.append('<textarea name="post[student_observations_attributes][' + index + '][content]""></textarea>');
  }
  

  // * Initialize *

  // Insert the student observation editor and button list
  obsEditor.insertAfter( obsFieldset.find( 'p:first' ) );
  buttonList.insertBefore( obsEditor );

  // Set up the section for each current student
  obsFieldset.find( '.fields' ).hide().each( function() {
    addButton( $(this).data( 'id' ), $(this).data( 'name' )); 
  });

  obsEditor.on('editorInit', function() {
    obsIframe = $('#observation-editor_ifr');
    checkHeight();
  });

  // Select the first student
  selectFirst();

  // Setup the buttons
  buttonList.on( 'click', 'a', function(e) {
    e.preventDefault();
    setSelected( $(this).parent('li').data('id') );
  });

  // Save content when the form is submitted
  $('form.post').on('submit', function() {
    if ( currentId() ) saveContent( currentId() );
  });

  // Add student observation when a student is tagged
  studentTagSelect.on( 'itemAdded', function( e, id, name ) {
    constructFields(id, name);
    addButton( id, name );
    checkHeight();

    if (obsFieldset.hasClass( 'empty' )) {
      obsFieldset.removeClass( 'empty' );
      setSelected( id );
    }
  });

  // Remove a student observation when a student is untagged
  studentTagSelect.on( 'itemRemoved', function( e, id, name ) {

    // Remove the fields and button
    obsFieldset.find( '.fields[data-id=' + id + ']' ).remove();
    removeButton( id );

    // Check if there are any fields left
    if ( obsFieldset.find( '.fields' ).length ) {
      selectFirst();
    }
    else {
      obsFieldset.addClass( 'empty' );
    }
  });
}

});