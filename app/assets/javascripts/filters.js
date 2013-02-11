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

  form.find('select').on('change', function() {
    form.submit();
  });

  var students = $('#student').hide();
  students.find('option:first').val(0).text(students.data('blank'));
  
  studentCollection = {};
  students.find('option').each(function() {
    studentCollection[$(this).val()] = $(this).text();
  });

  var studentMenu = $('<div></div>').addClass('menu').insertBefore(students);

  selectedStudent = students.find('option:selected').first();
  var studentTitle = $('<p></p>').addClass('title').addClass('student');
  studentTitle.text(selectedStudent.text());
  studentTitle.appendTo(studentMenu);


  var groups = $('#group').hide();
  groups.find('option:first').val(0).text(groups.data('blank'));
  
  groupCollection = {};
  groups.find('option').each(function() {
    groupCollection[$(this).val()] = $(this).text();
  });

  var groupMenu = $('<div></div>').addClass('menu').insertBefore(groups);

  selectedGroup = groups.find('option:selected').first();
  var groupTitle = $('<p></p>').addClass('title').addClass('group');
  groupTitle.text(selectedGroup.text());
  groupTitle.appendTo(groupMenu);
});