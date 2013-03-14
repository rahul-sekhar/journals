'use strict';

describe('editInPlace module', function() {
  beforeEach(module('journals.editInPlace'));

  /* -------- editInPlace directive ---------- */
  describe('editInPlace', function() {
    describe('conditional html escaping', function() {
      var scope, compile;

      beforeEach(inject(function($rootScope, $compile) {
        scope = $rootScope;
        compile = $compile;
      }));

      it('escapes html if the contains-html attribute is not set', function() {
        var elem = angular.element('<p edit-in-place="" edit-mode="editOn" type="text" editor-attr="" display="Some<br>text"></p>');
        compile(elem)(scope);
        scope.$apply();
        expect(elem.find('span.value').html()).toEqual('Some&lt;br&gt;text');
      });

      it('does not escape html if the contains-html attribute is set', function() {
        var elem = angular.element('<p edit-in-place="" edit-mode="editOn" type="text" contains-html editor-attr="" display="Some<br>text"></p>');
        compile(elem)(scope);
        scope.$apply();
        expect(elem.find('span.value').html()).toEqual('Some<br>text');
      });
    });

    describe('for a text field', function() {
      var elem, scope, rootScope, input, fieldSpan;

      beforeEach(inject(function($rootScope, $compile) {
        elem = angular.element('<p edit-in-place="someFunction(value)" edit-mode="editOn" type="text" editor-attr="someAttr" display="Some text"></p>').appendTo('body');
        rootScope = $rootScope
        scope = rootScope.$new();
        rootScope.someAttr = 'initial value';
        rootScope.someFunction = jasmine.createSpy();
        $compile(elem)(scope);
        scope.$apply();
        input = elem.find('input');
        fieldSpan = elem.find('span.value');
      }));

      it('adds a .container span', function() {
        expect(elem.children().length).toEqual(1);
        expect(elem.children('span.container').length).toEqual(1);
      });

      it('adds a .value span with the original contents, initially shown', function() {
        expect(fieldSpan.length).toEqual(1);
        expect(fieldSpan.text()).toEqual('Some text');
        expect(fieldSpan.is(':visible')).toEqual(true);
      });

      it('adds an initially hidden input element', function() {
        expect(input.length).toEqual(1);
        expect(input.is(':visible')).toEqual(false);
      });

      describe('when the linked editMode attribute of the parent scope is set to true', function() {
        beforeEach(function() {
          scope.editOn = true;
          scope.$apply();
        });

        it('hides the fieldSpan', function() {
          expect(fieldSpan.is(':visible')).toEqual(false);
        });

        it('shows the input', function() {
          expect(input.is(':visible')).toEqual(true);
        });
      });

      describe('when the field is clicked', function() {
        var timeout;

        beforeEach(inject(function($timeout) {
          spyOn($.fn, 'focus');
          fieldSpan.click();
          scope.$apply();
          timeout = $timeout;
        }));

        it('sets the input value to the attribute denoted by editInPlace', function() {
          expect(input.val()).toEqual('initial value');

          rootScope.someAttr = 'changed value';
          fieldSpan.click();
          expect(input.val()).toEqual('initial value');
        });

        it('does not change the editInPlace attribute when the input is changed', function() {
          input.val('some other val').trigger('input');
          scope.$apply();
          expect(rootScope.someAttr).toEqual('initial value');
        });

        it('hides the fieldSpan', function() {
          expect(fieldSpan.is(':visible')).toEqual(false);
        });

        it('shows and focuses on the input', function() {
          expect(input.is(':visible')).toEqual(true);
          timeout.flush();
          expect($.fn.focus).toHaveBeenCalled();
          expect($.fn.focus.mostRecentCall.object[0]).toEqual(input[0]);
        });

        describe('when the input value is changed', function() {
          beforeEach(function() {
            input.val('changed value').trigger('input');
            scope.$apply();
          });

          var runFinishEditExamples = function() {
            it('calls the parent function with the change value', function() {
              expect(rootScope.someFunction).toHaveBeenCalledWith('changed value');
            });

            it('does not modify the parent attribute', function() {
              expect(rootScope.someAttr).toEqual('initial value');
            });

            it('shows the fieldSpan', function() {
              expect(fieldSpan.is(':visible')).toEqual(true);
            });

            it('hides the input', function() {
              expect(input.is(':visible')).toEqual(false);
            });
          };

          describe('when enter is pressed', function() {
            beforeEach(function() {
              var press = $.Event("keydown");
              press.keyCode = 13;
              input.trigger(press);
            });

            runFinishEditExamples();
          });

          describe('when the input is blurred', function() {
            beforeEach(function() {
              input.blur();
            });

            runFinishEditExamples();
          });

          describe('when the escape key is pressed', function() {
            beforeEach(function() {
              var press = $.Event("keydown");
              press.keyCode = 27;
              input.trigger(press);
            });

            it('does not call the parent function', function() {
              expect(rootScope.someFunction).not.toHaveBeenCalled();
            });

            it('does not modify the parent attribute', function() {
              expect(rootScope.someAttr).toEqual('initial value');
            });

            it('shows the fieldSpan', function() {
              expect(fieldSpan.is(':visible')).toEqual(true);
            });

            it('hides the input', function() {
              expect(input.is(':visible')).toEqual(false);
            });
          });
        });
      });
    });
    
    describe('for a textarea field', function() {
      var elem, scope, rootScope, input, fieldSpan;

      beforeEach(inject(function($rootScope, $compile) {
        elem = angular.element('<p edit-in-place="someFunction(value)" type="textarea" edit-mode="editOn" editor-attr="someAttr" display="Some text"></p>').appendTo('body');
        rootScope = $rootScope
        scope = rootScope.$new();
        rootScope.someAttr = 'initial value';
        rootScope.someFunction = jasmine.createSpy();
        $compile(elem)(scope);
        scope.$apply();
        input = elem.find('textarea');
        fieldSpan = elem.find('span.value');
      }));

      it('adds an initially hidden textarea element', function() {
        expect(input.length).toEqual(1);
        expect(input.is(':visible')).toEqual(false);
      });

      describe('when the field is clicked', function() {
        var timeout;

        beforeEach(inject(function($timeout) {
          spyOn($.fn, 'focus');
          fieldSpan.click();
          scope.$apply();
          timeout = $timeout;
        }));

        it('sets the input value to the attribute denoted by editInPlace', function() {
          expect(input.val()).toEqual('initial value');

          rootScope.someAttr = 'changed value';
          fieldSpan.click();
          expect(input.val()).toEqual('initial value');
        });

        it('hides the fieldSpan', function() {
          expect(fieldSpan.is(':visible')).toEqual(false);
        });

        it('shows and focuses on the input', function() {
          expect(input.is(':visible')).toEqual(true);
          timeout.flush();
          expect($.fn.focus).toHaveBeenCalled();
          expect($.fn.focus.mostRecentCall.object[0]).toEqual(input[0]);
        });

        describe('when the input value is changed', function() {
          beforeEach(function() {
            input.val('changed value').trigger('input');
            scope.$apply();
          });

          var runFinishEditExamples = function() {
            it('calls the parent function with the change value', function() {
              expect(rootScope.someFunction).toHaveBeenCalledWith('changed value');
            });

            it('does not modify the parent attribute', function() {
              expect(rootScope.someAttr).toEqual('initial value');
            });

            it('shows the fieldSpan', function() {
              expect(fieldSpan.is(':visible')).toEqual(true);
            });

            it('hides the input', function() {
              expect(input.is(':visible')).toEqual(false);
            });
          };

          describe('when enter is pressed', function() {
            beforeEach(function() {
              var press = $.Event("keydown");
              press.keyCode = 13;
              input.trigger(press);
            });

            it('does not call the parent function', function() {
              expect(rootScope.someFunction).not.toHaveBeenCalled();
            });

            it('does not hide the input', function() {
              expect(input.is(':visible')).toEqual(true);
            });

            it('does not show the fieldSpan', function() {
              expect(fieldSpan.is(':visible')).toEqual(false);
            });
          });

          describe('when the input is blurred', function() {
            beforeEach(function() {
              input.blur();
            });

            runFinishEditExamples();
          });

          describe('when the escape key is pressed', function() {
            beforeEach(function() {
              var press = $.Event("keydown");
              press.keyCode = 27;
              input.trigger(press);
            });

            it('does not call the parent function', function() {
              expect(rootScope.someFunction).not.toHaveBeenCalled();
            });

            it('does not modify the parent attribute', function() {
              expect(rootScope.someAttr).toEqual('initial value');
            });

            it('shows the fieldSpan', function() {
              expect(fieldSpan.is(':visible')).toEqual(true);
            });

            it('hides the input', function() {
              expect(input.is(':visible')).toEqual(false);
            });
          });
        });
      });
    });

    describe('for an invalid type', function() {
      var elem, scope;

      beforeEach(inject(function($rootScope, $compile) {
        elem = angular.element('<p edit-in-place="someFunction(value)" type="other" edit-mode="editOn" editor-attr="someAttr">Some text</p>').appendTo('body');
        scope = $rootScope.$new();
        $compile(elem)(scope);
      }));

      it('should throw an exception', function() {
        expect(scope.$apply).toThrow('editInPlace type not recognized - other');
      });
    });
  });

  /* -------- editInPlace controller ---------- */
  describe('editInPlaceCtrl', function() {
    var scope, ctrl;

    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      scope.parentValue = 'initial value';
      ctrl = $controller('editInPlaceCtrl', { $scope: scope })
    }));

    it('does not set the editor value', function() {
      expect(scope.editorValue).toBeUndefined();
    });

    describe('startEdit()', function() {
      beforeEach(function() {
        scope.startEdit();
      });

      it('sets editMode to true', function() {
        expect(scope.editMode).toEqual(true);
      });
    });

    describe('when editMode is changed', function() {
      it('sets the editorValue to the parentValue if true', function() {
        scope.editMode = true;
        scope.$apply();
        expect(scope.editorValue).toEqual('initial value');
      });

      it('does nothing if false', function() {
        scope.editMode = false;
        scope.$apply();
        expect(scope.editorValue).toBeUndefined();
      });
    });

    describe('finishEdit()', function() {
      beforeEach(function() {
        scope.saveFn = jasmine.createSpy();
        scope.editorValue = 'someval';
        scope.editMode = true;
        scope.finishEdit();
      });
      
      it('calls saveFn with the editValue', function() {
        expect(scope.saveFn).toHaveBeenCalledWith({value: 'someval'});
      });

      it('sets editMode to false', function() {
        expect(scope.editMode).toEqual(false);
      });
    });

    describe('cancelEdit()', function() {
      beforeEach(function() {
        scope.editMode = true;
        scope.cancelEdit();
      });

      it('sets editMode to false', function() {
        expect(scope.editMode).toEqual(false);
      });
    });

    describe('clearEdit()', function() {
      beforeEach(function() {
        scope.saveFn = jasmine.createSpy();
        scope.editorValue = 'someval';
        scope.editMode = true;
        scope.clearEdit();
      });

      it('calls saveFn with a NULL value', function() {
        expect(scope.saveFn).toHaveBeenCalledWith({value: null});
      });

      it('sets editMode to false', function() {
        expect(scope.editMode).toEqual(false);
      });
    });
  });

  /* -------- focusOn directive ---------- */
  describe('focusOn', function() {
    var elem, scope, timeout;

    beforeEach(inject(function($rootScope, $compile, $timeout) {
      elem = angular.element('<input focus-on="someAttr" />');
      spyOn($.fn, 'focus');
      timeout = $timeout;
      scope = $rootScope;
      scope.someAttr = false;
      $compile(elem)(scope);
      scope.$apply();
    }));

    it('initially has no focus', function() {
      expect($.fn.focus).not.toHaveBeenCalled();
    });

    it('gains focus when someAttr is changed to true', function() {
      scope.someAttr = true;
      scope.$apply();
      timeout.flush();
      expect($.fn.focus).toHaveBeenCalled();
      expect($.fn.focus.mostRecentCall.object[0]).toEqual(elem[0]);
    });
  });
});