'use strict'

describe 'Controller: ProjectCtrl', ->

  # load the controller's module
  beforeEach module 'monthReportsApp'
  ProjectCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    ProjectCtrl = $controller 'ProjectCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1
