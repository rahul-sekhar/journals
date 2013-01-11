$(document).ready(function() {

  // Display and hide group and mentor dropdown menus
  var sections = $( '.profile .groups, .profile .mentors, .profile .mentees' );
  var menus = sections.find('.menu')

  function hideMenu( menu ) {
    menu.attr( 'data-fading', 1 );
    menu.fadeOut( 200, function() {
      menu.attr( 'data-fading', 0 );
      menu.attr( 'data-displayed', 0 );
    });
    menu.siblings('h4').removeClass('selected');
  }

  function showMenu( menu ) {
    menus.filter( '[data-displayed=1]' ).each( function(){ 
      hideMenu( $(this) );
    });

    menu.attr( 'data-fading', 1 );
    menu.fadeIn( 300, function() {
      menu.attr( 'data-fading', 0 );
    });
    menu.attr( 'data-displayed', 1 );
    menu.siblings('h4').addClass('selected');
  }

  sections.on( 'click', 'h4', function(e) {
    var menu = $(this).siblings( '.menu:first' );

    if ( menu.attr('data-displayed') == 1 ) {
      if ( menu.attr('data-fading') != 1 ) {
        hideMenu( menu );
      }
    }
    else {
      showMenu( menu );
    }
  });

  $(document).on('click', function(e) {
    menus.filter('[data-displayed=1]').each( function() {
      if ( $(e.target).closest(this).length == 0 && $(this).attr('data-fading') != 1 ) {
        hideMenu($(this));
      }
    })
    
  });
});