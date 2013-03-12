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
    
    describe('with a valid server response', function() {
      beforeEach(inject(function($injector) {
        httpBackend.expectGET('/groups').respond([{id: 2, name: 'Some group'}, {id: 10, name: 'Another group'}]);
        Groups = $injector.get('Groups');
        all_groups = Groups.all();
      }));

      describe('all()', function() {
        it('retrieves the groups', function() {
          httpBackend.flush();
          expect(all_groups).toEqualData([{id: 2, name: 'Some group'}, {id: 10, name: 'Another group'}]);
        });
      });

      describe('get(id)', function() {
        it('retrieves the specified group', function() {
          var result;
          Groups.get(10).then(function(obj) { result = obj });
          httpBackend.flush();
          expect(result).toEqualData({id: 10, name: 'Another group'});
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
        var window;

        beforeEach(inject(function($window) {
          window = $window
          httpBackend.flush();
        }));

        describe('when the user chooses cancel', function() {
          beforeEach(function() {
            spyOn(window, 'confirm').andReturn(false);
            all_groups[0].delete();
          });
          
          it('does not send a message to the server', function() {
            httpBackend.verifyNoOutstandingRequest();
          });

          it('does not set the deleted attribute of the group', function() {
            expect(all_groups).toEqualData([{id: 2, name: 'Some group'}, {id: 10, name: 'Another group'}]);
          });
        });

        describe('with a valid server response', function() {
          beforeEach(function() {
            spyOn(window, 'confirm').andReturn(true);
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
            spyOn(window, 'confirm').andReturn(true);
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

