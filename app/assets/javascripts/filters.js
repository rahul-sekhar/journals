$(document).ready( function() {
  var form = $('#filter-form')
  var searchBox = $('#search');
  
  if ( searchBox.length > 0 ) {
    var initialVal = searchBox.val();

    // Check when enter is pressed on the search box
    searchBox.on( 'keyup', function(e) {
      if ( e.keyCode == 13 ) {
        doSearch();
      }
    });

    // Check for a change event of the search box
    searchBox.on('change', function() {
      console.log('changed');
      doSearch();
    });

    // Perform a search if the query is different from the current one
    function doSearch() {
      var currentVal = searchBox.val();

      if (currentVal != initialVal) {
        form.submit();
      }
    }
  }
});