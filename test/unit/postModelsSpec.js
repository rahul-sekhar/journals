'use strict';

describe('post models module', function () {
  beforeEach(module('journals.posts.models'));

  describe('Models with associations', function () {
    var collection, model, association, singleAssociation;

    beforeEach(module(function ($provide) {
      model = jasmine.createSpy().andReturn('model');
      collection = jasmine.createSpy().andReturn('collection');

      association = jasmine.createSpy().andCallFake(function (arg1, name) {
        return name + ' association';
      });
      singleAssociation = jasmine.createSpy().andCallFake(function (arg1, name) {
        return name + ' association';
      });

      $provide.value('model', model);
      $provide.value('collection', collection);
      $provide.value('association', association);
      $provide.value('singleAssociation', singleAssociation);
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
});