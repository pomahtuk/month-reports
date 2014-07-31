'use strict'

describe 'Controller: ExpensearticleCtrl', ->

  # load the controller's module
  beforeEach module 'monthReportsApp'
  ExpensearticleCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    ExpensearticleCtrl = $controller 'ExpensearticleCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1
