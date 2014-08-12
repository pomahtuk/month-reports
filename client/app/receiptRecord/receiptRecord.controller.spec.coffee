'use strict'

describe 'Controller: ReceiptrecordCtrl', ->

  # load the controller's module
  beforeEach module 'monthReportsApp'
  ReceiptrecordCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    ReceiptrecordCtrl = $controller 'ReceiptrecordCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1
