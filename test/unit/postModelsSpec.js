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
  });

  /*------------------------- Post extension -----------------------*/

  describe('guardianExtension', function () {
    var extension, instance;

    beforeEach(inject(function (postExtension) {
      extension = postExtension();
      instance = {};
    }));

    it('is a blank function', function () {
      extension(instance);
      expect(instance).toEqual({});
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