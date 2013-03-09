'use strict';

describe('Groups module', function() {  
  beforeEach(module('journals.groups'));

  /*---------- Groups service -----------------*/

  describe('Groups', function() {
    var Groups, httpBackend, messageHandler, all_groups;

    beforeEach(inject(function($httpBackend, _messageHandler_, _Groups_) {
      httpBackend = $httpBackend;
      messageHandler = _messageHandler_;
      spyOn(messageHandler, 'showError');
      Groups = _Groups_;
    }));

    it('does not initially load groups', function() {
      httpBackend.verifyNoOutstandingExpectation();
    });

    describe('on a call to the all function', function() {
      it('loads groups', function() {
        httpBackend.expectGET('/groups').respond([]);
        Groups.all();
        httpBackend.verifyNoOutstandingExpectation();
      });

      it('does not reload groups if the groups have already been loaded', function() {
        httpBackend.expectGET('/groups').respond([]);
        Groups.all();
        httpBackend.flush();
        Groups.all();
        httpBackend.verifyNoOutstandingExpectation();
      });

      it('reloads groups if the groups have failed to load after a timeout', inject(function($timeout) {
        httpBackend.expectGET('/groups').respond(404);
        Groups.all();
        httpBackend.flush();
        Groups.all();
        httpBackend.verifyNoOutstandingExpectation();

        httpBackend.expectGET('/groups').respond([]);
        $timeout.flush();
        Groups.all();
        httpBackend.verifyNoOutstandingExpectation();
      }));
    });

    describe('get(id)', function() {
      it('loads groups', function() {
        httpBackend.expectGET('/groups').respond([]);
        Groups.get(5);
        httpBackend.verifyNoOutstandingExpectation();
      });

      it('does not reload groups if the groups have already been loaded', function() {
        httpBackend.expectGET('/groups').respond([]);
        Groups.all();
        httpBackend.flush();
        Groups.get(3);
        httpBackend.verifyNoOutstandingExpectation();
      });

      it('reloads groups if the groups have failed to load', inject(function($timeout) {
        httpBackend.expectGET('/groups').respond(404);
        Groups.all();
        httpBackend.flush();
        Groups.get(7);
        httpBackend.verifyNoOutstandingExpectation();

        httpBackend.expectGET('/groups').respond([]);
        $timeout.flush();
        Groups.get(7);
        httpBackend.verifyNoOutstandingExpectation();
      }));

      describe('the returned promise', function() {
        var success, error;

        beforeEach(function() {
          success = jasmine.createSpy('success'), error = jasmine.createSpy('error');
        });

        it('is resolved with the relevant group with a valid server response', function() {
          httpBackend.expectGET('/groups').respond([{id: 1, name: "One"}, {id: 5, name: "Five"}, {id: 7, name: "Seven"}]);
          Groups.get(5).then(success, error);
          expect(success).not.toHaveBeenCalled();
          httpBackend.flush();
          expect(success).toHaveBeenCalled();
          expect(success.mostRecentCall.args[0]).toEqualData({id: 5, name: "Five"});
        });

        it('is rejected if the group is not present', function() {
          httpBackend.expectGET('/groups').respond([{id: 1, name: "One"}, {id: 6, name: "Six"}, {id: 7, name: "Seven"}]);
          Groups.get(5).then(success, error);
          httpBackend.flush();
          expect(success).not.toHaveBeenCalled();
          expect(error).toHaveBeenCalled();
        });

        it('is rejected for an invalid server response', function() {
          httpBackend.expectGET('/groups').respond(404, 'Some error');
          Groups.get(5).then(success, error);
          httpBackend.flush();
          expect(success).not.toHaveBeenCalled();
          expect(error).toHaveBeenCalled();
        });
      });
    });
    
    describe('with a valid server response', function() {
      beforeEach(inject(function($injector) {
        httpBackend.expectGET('/groups').respond([{id: 2, name: 'Some group'}, {id: 10, name: 'Another group'}]);
        Groups = $injector.get('Groups');
        all_groups = Groups.all();
      }));

      describe('all()', function() {
        it('updates references to the function with the loaded data', function() {
          expect(all_groups).toEqual([]);
          httpBackend.flush();
          expect(all_groups).toEqualData([{id: 2, name: 'Some group'}, {id: 10, name: 'Another group'}]);
        });
      });

      describe('add()', function() {
        var group;

        beforeEach(function() {
          httpBackend.flush();
          group = Groups.add();
        });

        it('creates an empty group with editing set to true', function() {
          expect(all_groups).toEqualData([{editing: true}, {id: 2, name: 'Some group'}, {id: 10, name: 'Another group'}]);
        });

        describe('save the group instance through rename()', function() {
          describe('with a valid server response', function() {
            beforeEach(function() {
              httpBackend.expectPOST('/groups', {group: {name: 'New group'}}).
                respond({id: 3, name: 'Formatted name'});
              
              delete group.editing;
              group.rename('New group');
            });

            it('sends a message to the server', function() {
              httpBackend.verifyNoOutstandingExpectation();
            });
            
            it('creates the group and updates its name on response from the server', function() {
              expect(all_groups).toEqualData([{name: 'New group'}, {id: 2, name: 'Some group'}, {id: 10, name: 'Another group'}]);
              httpBackend.flush();
              expect(all_groups).toEqualData([{id: 3, name: 'Formatted name'}, {id: 2, name: 'Some group'}, {id: 10, name: 'Another group'}]);
            });
          });
          
          describe('with an invalid server response', function() {
            beforeEach(function() {
              httpBackend.expectPOST('/groups', {group: {name: 'New group'}}).
                respond(422, 'Some error');
              
              delete group.editing;
              group.rename('New group');
            });

            it('sends a message to the server', function() {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('creates the group and deletes it on response from the server', function() {
              expect(all_groups).toEqualData([{name: 'New group'}, {id: 2, name: 'Some group'}, {id: 10, name: 'Another group'}]);
              httpBackend.flush();
              expect(all_groups).toEqualData([{id: 2, name: 'Some group'}, {id: 10, name: 'Another group'}]);
            });

            it('sends an error to the messageHandler', function() {
              httpBackend.flush();
              expect(messageHandler.showError).toHaveBeenCalled();
              expect(messageHandler.showError.mostRecentCall.args[0].data).toEqual('Some error');
            });
          });
          
          describe('with a blank name', function() {
            beforeEach(function() {
              group.rename('');
            });

            it('sends no message to the server', function() {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('removes the group', function() {
              httpBackend.verifyNoOutstandingRequest();
              expect(all_groups).toEqualData([{id: 2, name: 'Some group'}, {id: 10, name: 'Another group'}]);
            });
          });
        });
      });

      describe('delete a group instance', function() {
        beforeEach(function() {
          httpBackend.flush();
        });

        describe('with a valid server response', function() {
          beforeEach(function() {
            httpBackend.expectDELETE('/groups/2').respond(200, 'OK');
            all_groups[0].delete();
          });

          it('sets the deleted attribute of the group', function() {
            expect(all_groups).toEqualData([{id: 2, name: 'Some group', deleted: true}, {id: 10, name: 'Another group'}]);
          });

          it('sends a delete message to the server', function() {
            httpBackend.verifyNoOutstandingExpectation();
          });

          it('removes the group from the groups array on response from the server', function() {
            httpBackend.flush();
            expect(all_groups).toEqualData([{id: 10, name: 'Another group'}])
          });

          it('does not remove any group if the group does not exist', function() {
            all_groups.splice(0, 1);
            httpBackend.flush();
            expect(all_groups).toEqualData([{id: 10, name: 'Another group'}])
          });
        });

        describe('with an invalid server response', function() {
          beforeEach(function() {
            httpBackend.expectDELETE('/groups/2').respond(422, 'Some error');
            all_groups[0].delete();
          });

          it('sets the deleted attribute of the group and removes it after getting a response', function() {
            expect(all_groups).toEqualData([{id: 2, name: 'Some group', deleted: true}, {id: 10, name: 'Another group'}]);
            httpBackend.flush();
            expect(all_groups).toEqualData([{id: 2, name: 'Some group'}, {id: 10, name: 'Another group'}]);
          });

          it('sends a delete message to the server', function() {
            httpBackend.verifyNoOutstandingExpectation();
          });

          it('sends an error to the messageHandler', function() {
            httpBackend.flush();
            expect(messageHandler.showError).toHaveBeenCalled();
            expect(messageHandler.showError.mostRecentCall.args[0].data).toEqual('Some error');
          });

          it('does not remove the group', function() {
            httpBackend.flush();
            expect(all_groups).toEqualData([{id: 2, name: 'Some group'}, {id: 10, name: 'Another group'}]);
          });
        });
      });

      describe('rename a group instance', function() {
        beforeEach(function() {
          httpBackend.flush();
        });

        describe('with a valid server response', function() {
          beforeEach(function() {
            httpBackend.expectPUT('/groups/10', {group: {name: 'Renamed group'}}).
              respond({id: 10, name: 'Formatted name'});
            all_groups[1].rename('Renamed group');
          });

          it('sends a message to the server', function() {
            httpBackend.verifyNoOutstandingExpectation();
          });

          it('renames the group and updates its name on response from the server', function() {
            expect(all_groups).toEqualData([{id: 2, name: 'Some group'}, {id: 10, name: 'Renamed group'}]);
            httpBackend.flush();
            expect(all_groups).toEqualData([{id: 2, name: 'Some group'}, {id: 10, name: 'Formatted name'}]);
          });
        });
        
        describe('with an invalid server response', function() {
          beforeEach(function() {
            httpBackend.expectPUT('/groups/10', {group: {name: 'Renamed group'}}).
              respond(422, 'Some error');
            all_groups[1].rename('Renamed group');
          });

          it('sends a message to the server', function() {
            httpBackend.verifyNoOutstandingExpectation();
          });

          it('renames the group and restores its name on response from the server', function() {
            expect(all_groups).toEqualData([{id: 2, name: 'Some group'}, {id: 10, name: 'Renamed group'}]);
            httpBackend.flush();
            expect(all_groups).toEqualData([{id: 2, name: 'Some group'}, {id: 10, name: 'Another group'}]);
          });

          it('sends an error to the messageHandler', function() {
            httpBackend.flush();
            expect(messageHandler.showError).toHaveBeenCalled();
            expect(messageHandler.showError.mostRecentCall.args[0].data).toEqual('Some error');
          });
        });

        describe('with an unchanged name', function() {
          beforeEach(function() {
            all_groups[1].rename('Another group');
          });

          it('sends no message to the server', function() {
            httpBackend.verifyNoOutstandingExpectation();
          });

          it('leaves the group as is', function() {
            httpBackend.verifyNoOutstandingRequest();
            expect(all_groups).toEqualData([{id: 2, name: 'Some group'}, {id: 10, name: 'Another group'}]);
          });
        });
      });
    });

    describe('with an invalid server response', function() {
      beforeEach(inject(function($injector) {
        httpBackend.expectGET('/groups').respond(404, 'Some error');
        Groups = $injector.get('Groups');
        all_groups = Groups.all();
      }));

      describe('all()', function() {
        it('sends an error to the messageHandler', function() {
          httpBackend.flush();
          expect(messageHandler.showError).toHaveBeenCalled();
          expect(messageHandler.showError.mostRecentCall.args[0].data).toEqual('Some error');
        });

        it('updates references to the function to an empty array', function() {
          expect(all_groups).toEqual([]);
          httpBackend.flush();
          expect(all_groups).toEqual([]);
        });
      });
    });
  });

  /*---------- Groups controller --------------------*/
  describe('GroupsCtrl', function() {
    var scope, ctrl, Groups;

    beforeEach(inject(function($rootScope, $controller, $injector) {
      Groups = { all: jasmine.createSpy('Groups.all').
        andReturn([{id: 1, name: 'One'}, {id: 3, name: 'Three'}]) };

      scope = $rootScope.$new();
      ctrl = $controller('GroupsCtrl', { $scope: scope, Groups: Groups });
    }));

    it('sets groups to the value of Groups.all()', function() {
      expect(Groups.all).toHaveBeenCalled();
      expect(scope.groups).toEqual([{id: 1, name: 'One'}, {id: 3, name: 'Three'}]);
    });

    describe('add()', function() {
      beforeEach(function() {
        Groups.add = jasmine.createSpy('Groups.add');
        scope.add();
      });

      it('adds alls Groups.add()', function() {
        expect(Groups.add).toHaveBeenCalled();
      });
    });
  });
});

