'use strict';

angular.module('journals.tinymce', ['journals.fileUpload']).

  directive('tinymce', [function () {
    tinyMCE.baseURL = '/tinymce/';
    // Image upload function
    tinymce.create('tinymce.plugins.ngImage', {
      init: function (editor, url) {
        editor.addCommand('ngImage', function() {
          $('#' + editor.editorId).trigger('ngImageClick');
        });

        editor.addButton('ngimage', {
          title : 'Insert image',
          cmd : 'ngImage',
          class: 'mce_image'
        });
      }
    });

    tinymce.PluginManager.add('ngimage', tinymce.plugins.ngImage);

    return {
      restrict: 'E',
      scope: {
        ngModelAttr: '='
      },
      template: '<div class="tinymce-wrapper">' +
        '<textarea ng-model="ngModelAttr"></textarea>' +
        '<modal class="image-dialog" show-on="imageDialogShown">' +
          '<p>Upload an image</p>' +
          '<file-upload url="/images.json" on-upload="imageUploaded(imageData)"></file-upload>' +
          '<button ng-click="cancelImage()">Cancel</button>' +
        '</modal>' +
        '</div>',
      replace: true,

      link: function(scope, elem, attrs) {
        var saveFn, editor;
        editor = elem.find('textarea:first');

        if (attrs.editorId) {
          editor.attr('id', attrs.editorId);
        }

        editor.tinymce({
          popup_css : "/tinymce/themes/advanced/skins/default/dialog.css",
          width: 474,
          theme : "advanced",
          plugins : "autolink,lists,inlinepopups,paste,-ngimage",
          content_css: "/assets/tinymce/main.css",
          theme_advanced_buttons1 : "bold,italic,strikethrough,|,link,unlink,|,bullist,numlist,|,ngimage",
          theme_advanced_toolbar_location : "top",
          theme_advanced_toolbar_align : "center",
          theme_advanced_resizing : true,
          theme_advanced_resize_horizontal : false,
          theme_advanced_statusbar_location : "bottom",
          theme_advanced_path: false,
          relative_urls: false,
          formats: {
            strikethrough : { inline : 'span', 'classes' : 'strikethrough', exact : true }
          },
          onchange_callback: function(e) {
            if (this.isDirty()) {
              saveFn();
              return true;
            }
          },
          oninit: function() {
            editor.trigger('editorInit');
          }
        });

        saveFn = function() {
          editor.tinymce().save();
          scope.ngModelAttr = editor.val();
        };

        scope.$on('saveText', function () {
          saveFn();
        });

        // Image upload hooks
        editor.on('ngImageClick', function () {
          scope.$apply(function () {
            scope.$broadcast('resetUpload');
            scope.imageDialogShown = true;
          });
        });

        scope.cancelImage = function () {
          scope.$broadcast('cancelUpload');
          scope.imageDialogShown = false;
        };

        scope.imageUploaded = function (imageData) {
          scope.imageDialogShown = false;
          editor.tinymce().execCommand('mceInsertContent', false, '<img src="' + imageData.url + '" alt="" />');
          scope.$emit('imageUploaded', imageData);
        };
      }
    };
  }]);