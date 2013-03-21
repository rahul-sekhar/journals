'use strict';

describe('post models module', function () {
  beforeEach(module('journals.posts.models'));

  describe('Models with associations', function () {
    var collection, model, association, singleAssociation, postExtension;

    beforeEach(module(function ($provide) {
      model = jasmine.createSpy().andReturn('model');
      collection = jasmine.createSpy().andReturn('collection');

      association = jasmine.createSpy().andCallFake(function (arg1, name) {
        return name + ' association';
      });
      singleAssociation = jasmine.createSpy().andCallFake(function (arg1, name) {
        return name + ' association';
      });
      postExtension = jasmine.createSpy().andReturn('postExtension');

      $provide.value('model', model);
      $provide.value('collection', collection);
      $provide.value('association', association);
      $provide.value('singleAssociation', singleAssociation);
      $provide.value('postExtension', postExtension);
    }));


    /*------------------- Posts collection -----------------------*/

    describe('Posts', function () {
      var Posts;

      beforeEach(inject(function (_Posts_) {
        Posts = _Posts_;
      }));

      it('sets the model name', function () {
        expect(model.mostRecentCall.args[0]).toEqual('post');
      });

      it('sets the model url', function () {
        expect(model.mostRecentCall.args[1]).toEqual('/posts');
      });

      it('sets the extensions', function () {
        expect(model.mostRecentCall.args[2].extensions).toEqual([
          'author association',
          'student association',
          'teacher association',
          'comment association',
          'student_observation association',
          'postExtension'
        ]);
      });

      it('calls the collection with the model object', function () {
        expect(collection).toHaveBeenCalledWith('model');
      });

      it('returns the collection object', function () {
        expect(Posts).toEqual('collection');
      });
    });



    /*---------------------- Comments collection --------------------*/

    describe('Comments', function () {
      var Comments;

      beforeEach(inject(function (_Comments_) {
        Comments = _Comments_;
      }));

      it('sets the model name', function () {
        expect(model.mostRecentCall.args[0]).toEqual('comment');
      });

      it('sets the model url to null', function () {
        expect(model.mostRecentCall.args[1]).toEqual('/comments');
      });

      it('sets the extensions', function () {
        expect(model.mostRecentCall.args[2].extensions).toEqual([
          'author association',
        ]);
      });

      it('calls the collection with the model object', function () {
        expect(collection).toHaveBeenCalledWith('model');
      });

      it('returns the collection object', function () {
        expect(Comments).toEqual('collection');
      });
    });



    /*---------------------- Student Observations collection --------------------*/

    describe('StudentObservations', function () {
      var StudentObservations;

      beforeEach(inject(function (_StudentObservations_) {
        StudentObservations = _StudentObservations_;
      }));

      it('sets the model name', function () {
        expect(model.mostRecentCall.args[0]).toEqual('student_observation');
      });

      it('sets the model url to null', function () {
        expect(model.mostRecentCall.args[1]).toBeNull();
      });

      it('sets the extensions', function () {
        expect(model.mostRecentCall.args[2].extensions).toEqual([
          'student association',
        ]);
      });

      it('calls the collection with the model object', function () {
        expect(collection).toHaveBeenCalledWith('model');
      });

      it('returns the collection object', function () {
        expect(StudentObservations).toEqual('collection');
      });
    });
  });

  /*------------------------- Post extension -----------------------*/

  describe('postExtension', function () {
    var extension, instance;

    beforeEach(inject(function (postExtension) {
      extension = postExtension();
      instance = {};
    }));

    describe('on load', function () {
      describe('with no student observations', function () {
        beforeEach(function () {
          extension(instance);
        });

        it('adds empty observation objects', function () {
          expect(instance).toEqual({ observationContent: {}, observationId: {} });
        });
      });

      describe('with student observations', function () {
        beforeEach(function () {
          instance.student_observations = [
            {id: 2, student_id: 5, content: 'Some obs'},
            {id: 5, student_id: 7, content: 'Other obs'},
            {student_id: 15, content: 'Another obs'}
          ]
          extension(instance);
        });

        it('adds observationContent objects', function () {
          expect(instance.observationContent).toEqualData({
            5: 'Some obs',
            7: 'Other obs',
            15: 'Another obs'
          });
        });

        it('adds observationId objects', function () {
          expect(instance.observationId).toEqualData({
            5: 2,
            7: 5
          });
        });
      });
    });

    describe('beforeSave()', function () {
      describe('with no observation data', function () {
        beforeEach(function () {
          extension.beforeSave(instance);
        });

        it('adds an empty student_observations_attributes array', function () {
          expect(instance).toEqual({ student_observations_attributes: [] });
        });
      });

      describe('with observation data', function () {
        beforeEach(function () {
          instance.observationContent = {
            6: 'Some content',
            9: 'Other content',
            15: 'Blah blah blah'
          };
          instance.observationId = {
            9: 26,
            5: 15
          };
          extension.beforeSave(instance);
        });

        it('sets up student_observations_attributes, ignoring ids with no content data', function () {
          expect(instance.student_observations_attributes).toEqualData([
            {student_id: 6, content: 'Some content'},
            {id: 26, student_id: 9, content: 'Other content'},
            {student_id: 15, content: 'Blah blah blah'}
          ]);
        });
      });

      describe('on loading student observations, with no change after', function () {
        beforeEach(function () {
          instance.student_observations = [
            {id: 2, student_id: 5, content: 'Some obs'},
            {id: 5, student_id: 7, content: 'Other obs'},
            {student_id: 15, content: 'Another obs'}
          ]
          extension(instance);
          extension.beforeSave(instance);
        });

        it('translates the student_observations directly to the attributes', function () {
          expect(instance.student_observations_attributes).toEqualData(instance.student_observations);
        });
      });
    });

    describe('setup()', function () {
      beforeEach(function () {
        extension.setup(instance);
      });

      describe('restrictions()', function () {
        it('returns null when neither visibility attribute is set', function () {
          expect(instance.restrictions()).toBeNull();
        });

        it('returns null when visibilities are set to true', function () {
          instance.visible_to_guardians = true;
          instance.visible_to_students = true;
          expect(instance.restrictions()).toBeNull();
        });

        it('returns a message when the student visibility is set to false', function () {
          instance.visible_to_guardians = true;
          instance.visible_to_students = false;
          expect(instance.restrictions()).toEqual('Not visible to students');
        });

        it('returns a message when the guardian visibility is set to false', function () {
          instance.visible_to_guardians = false;
          instance.visible_to_students = true;
          expect(instance.restrictions()).toEqual('Not visible to guardians');
        });

        it('returns a message when both visibilities are set to false', function () {
          instance.visible_to_guardians = false;
          instance.visible_to_students = false;
          expect(instance.restrictions()).toEqual('Not visible to students or guardians');
        });
      });
    });
  });
});