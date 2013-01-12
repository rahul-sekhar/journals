//= require ./jquery.tinymce.js

$(document).ready(function() {
  $('#post_content, #observation-editor').tinymce({
      script_url : '/tiny_mce/tiny_mce.js',
      width: 474,
      theme : "advanced",
      plugins : "autolink,lists,inlinepopups,paste",
      content_css: "/assets/tinymce/main.css",
      theme_advanced_buttons1 : "bold,italic,strikethrough,|,link,unlink,|,bullist,numlist,|,code",
      theme_advanced_toolbar_location : "top",
      theme_advanced_toolbar_align : "center",
      theme_advanced_resizing : true,
      theme_advanced_resize_horizontal : false,
      theme_advanced_statusbar_location : "bottom",
      theme_advanced_path: false,
      relative_urls: false,
      formats: {
        underline : { inline : 'span', 'classes' : 'underline', exact : true }
      },
      oninit: function() {
        $('#post_content, #observation-editor').trigger('editorInit');
      }
  });
});