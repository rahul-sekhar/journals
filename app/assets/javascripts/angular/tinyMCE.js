'use strict';

angular.module('journals.tinymce', ['journals.fileUpload']).

  directive('tinymce', ['imageDialog', function (imageDialog) {
    tinyMCE.baseURL = '/tinymce/';

    return {
      require: 'ngModel',
      link: function(scope, elem, attrs, ngModel) {
        var saveFn;

        elem.tinymce({
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
            elem.trigger('editorInit');
          }
        });

        saveFn = function() {
          elem.tinymce().save();
          ngModel.$setViewValue(elem.val());
        };

        scope.$on('saveText', function () {
          saveFn();
        });
      }
    };
  }]).

  factory('imageDialog', ['$compile', '$rootScope', function ($compile, $rootScope) {
    var modal, scope, currentEditor;

    // Set up dialog
    modal = angular.element('<modal id="image-upload-dialog" show-on="imageDialogShown">' +
      '<p>Upload an image</p>' +
      '<file-upload url="/images.json" on-upload="uploaded(imageData)"></file-upload>' +
      '<button ng-click="cancel()">Cancel</button>' +
    '</modal>');

    modal.appendTo('body')
    scope = $rootScope.$new();
    modal = $compile(modal)(scope);

    scope.cancel = function () {
      scope.imageDialogShown = false;
    };

    scope.$watch('imageDialogShown', function (value) {
      if (value === false) {
        scope.$broadcast('cancelUpload');
      }
    });

    scope.uploaded = function (imageData) {
      scope.imageDialogShown = false;
      currentEditor.execCommand('mceInsertContent', false, '<img src="' + imageData.url + '" alt="" />');
      $rootScope.$broadcast('imageUploaded', imageData);
    };

    // Set up plugin
    tinymce.create('tinymce.plugins.ngImage', {
      init: function (editor, url) {
        editor.addCommand('ngImage', function() {
          scope.$broadcast('resetUpload');
          currentEditor = editor;
          scope.imageDialogShown = true;
        });

        editor.addButton('ngimage', {
          title : 'Insert image',
          cmd : 'ngImage',
          class: 'mce_image'
        });
      }
    });

    tinymce.PluginManager.add('ngimage', tinymce.plugins.ngImage);
  }]);