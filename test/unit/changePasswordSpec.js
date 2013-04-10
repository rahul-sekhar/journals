'use strict';

describe('changePassword module', function() {
  beforeEach(module('journals.changePassword'));

  describe('ChangePasswordCtrl', function() {
    var scope, httpBackend, dialogs;

    beforeEach(inject(function($rootScope, $controller, $httpBackend) {
      httpBackend = $httpBackend;

      scope = $rootScope.$new();
      dialogs = {};
      $rootScope.dialogs = dialogs;
      $controller('ChangePasswordCtrl', { $scope: scope });
    }));

    it('sets the scope user to a blank object when the dialog status is changed', function () {
      scope.user = { data: 'val' };
      dialogs.changePassword = true;
      scope.$apply();
      expect(scope.user).toEqual({});
    });

    describe('submit()', function() {
      beforeEach(function () {
        scope.user = { data: 'val' };
      });

      describe('on success', function () {
        beforeEach(function() {
          httpBackend.expectPUT('/change_password.json', { user: { data: 'val' } }).respond(200);
          scope.submit();
        });

        it('sends a PUT request', function () {
          httpBackend.verifyNoOutstandingExpectation();
        });

        it('closes the dialog', function () {
          httpBackend.flush();
          expect(dialogs.changePassword).toEqual(false);
        });
      });

      describe('on failure', function () {
        beforeEach(function() {
          httpBackend.expectPUT('/change_password.json', { user: { data: 'val' } }).respond(422);
          scope.submit();
        });

        it('does not close dialog', function () {
          httpBackend.flush();
          expect(dialogs.changePassword).toBeUndefined();
        });
      });
    });
  });
});