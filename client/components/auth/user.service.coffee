'use strict'

angular.module('monthReportsApp').factory 'User', [
  '$resource'
  ($resource) ->
    $resource '/api/users/:id/:controller',
      id: '@_id'
    ,
      changePassword:
        method: 'PUT'
        params:
          controller: 'password'

      get:
        method: 'GET'
        params:
          id: 'me'
  ]
