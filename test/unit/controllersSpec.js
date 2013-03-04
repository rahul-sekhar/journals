
  
//   describe('GroupsCtrl', function() {
//     var scope, ctrl, $httpBackend, dialogHandlerMock;

//     beforeEach(inject(function($rootScope, $controller, _$httpBackend_) {
//       $httpBackend = _$httpBackend_;
//       $httpBackend.expectGET('/groups').respond([{name: "Group 1", id: 5}, {name: "Group 2", id: 10}]);
//       dialogHandlerMock = { message: jasmine.createSpy() };
//       scope = $rootScope.$new();
//       ctrl = $controller(GroupsCtrl, { $scope: scope, dialogHandler: dialogHandlerMock });
//     }));

//     it('retrieves a list of groups', function() {
//       expect(scope.groups).toEqualData([]);
//       $httpBackend.flush();
//       expect(scope.groups).toEqualData([{name: "Group 1", id: 5}, {name: "Group 2", id: 10}]);
//     });

//     it('sets the default type', function() {
//       expect(scope.defaultType).toEqual('groups');
//     });

//     describe('delete()', function() {
//       beforeEach(function() {
//         $httpBackend.flush();
//         $httpBackend.expectDELETE('/groups/5').respond(200);
//         scope.delete(scope.groups[0]);
//       });

//       it('removes the group from the groups array', function() {
//         expect(scope.groups).toEqualData([{name: "Group 2", id: 10}]);
//       });

//       it('sends a delete request', function() {
//         $httpBackend.verifyNoOutstandingExpectation();
//       });
//     });

//     describe('add()', function() {
//       beforeEach(function() {
//         $httpBackend.flush();
//       });

//       it('adds a new group with a blank name to the groups array, in the first position', function() {
//         scope.add();
//         expect(scope.groups).toEqualData([{name: ""},{name: "Group 1", id: 5}, {name: "Group 2", id: 10}])
//       });

//       describe('the added group', function() {
//         var group;
        
//         beforeEach(function() {
//           scope.add();
//           group = scope.groups[0]
//         });

//         describe('destroy()', function() {
//           it('removes the group from the groups array', function() {
//             group.destroy();
//             expect(scope.groups).toEqualData([{name: "Group 1", id: 5}, {name: "Group 2", id: 10}])
//           });
//         });

//         describe('create()', function() {
//           describe('on success', function() {
//             beforeEach(function() {
//               $httpBackend.expectPOST('/groups', {group: {name: 'blah'}}).respond({name: 'blah', id: 56});
//               group.create({group: {name: 'blah'}});
//             });

//             it('posts the data to the server', function() {
//               $httpBackend.verifyNoOutstandingExpectation();
//             });

//             it('updates the group in the array', function() {
//               $httpBackend.flush();
//               expect(scope.groups).toEqualData([{name: 'blah', id: 56}, {name: "Group 1", id: 5}, {name: "Group 2", id: 10}])
//             });
//           });
          
//           describe('on failure', function() {
//             beforeEach(function() {
//               $httpBackend.expectPOST('/groups', {group: {name: 'blah'}}).respond(422, 'error!');
//               group.create({group: {name: 'blah'}});
//             });

//             it('removes the group from the array', function() {
//               $httpBackend.flush();
//               expect(scope.groups).toEqualData([{name: "Group 1", id: 5}, {name: "Group 2", id: 10}])
//             });

//             it('displays an error message', function() {
//               $httpBackend.flush();
//               expect(dialogHandlerMock.message).toHaveBeenCalledWith('error!');
//             });            
//           });
//         });
//       });
//     });
//   });
// });

