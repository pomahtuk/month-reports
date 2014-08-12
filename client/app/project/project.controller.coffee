'use strict'

angular.module 'monthReportsApp'
.controller 'ProjectCtrl', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $scope.projects = []
    $scope.newProject = {}
    $scope.saveChanges = false

    $http.get('/api/projects').success (projects) ->
      $scope.projects = projects
    .error (data) ->
      console.log data

    $scope.gridOptions =
      data: 'projects'
      enableCellSelection: true
      enableRowSelection: false
      enableCellEdit: true
      columnDefs: [
        {
          field:'name_ru',
          displayName:'Russian name'
          enableCellEdit: true
        }
        {
          field:'name_en',
          displayName:'English name'
          enableCellEdit: true
        }
        {
          displayName: ''
          width: 50
          enableCellEdit: false
          cellTemplate: '
            <div class="ngCellText" ng-class="col.colIndex()">
              <span class="trash" ng-click="delete(row.entity)">
                <span class="glyphicon glyphicon-trash"></span>
              </span>
            </div>
          '
        }
      ]

    $scope.$on 'ngGridEventEndCellEdit', ->
      $scope.saveChanges = true

    $scope.$watch 'projects', (newVal, oldVal) ->
      setTimeout ->
        if $scope.saveChanges is true
          if newVal?
            if newVal.length is oldVal.length
              for item, index in newVal
                oldItem = oldVal[index]
                for key, value of item
                  oldFieldVal = oldItem[key]
                  if oldFieldVal isnt value
                    $scope.saveChanges = false
                    $http.put('/api/projects/' + item._id, item).success (data) ->
                      console.log 'ok'
                    .error ((data) ->
                      item = oldItem
                    ).bind {
                      item: item
                      oldItem: oldItem
                    }
                    break
      , 200
    , true

    $scope.delete = (project) ->
      ##
      ## TODO: confirm!
      ##
      if confirm 'Are you sure you want to delete this record?'
        $http.delete('/api/projects/' + project._id).success (data) ->
          for proj, index in $scope.projects
            $scope.projects.splice index, 1  if proj._id is project._id
        .error (data) ->
          console.log data

    $scope.resetFrom = ->
      $scope.newProject = {}

    $scope.createProject = ->
      if $scope.newProject.name_ru? and $scope.newProject.name_en?
        $http.post('/api/projects', $scope.newProject).success (project) ->
          $scope.projects.push project
          $scope.addProject = false
          $scope.newProject = {}
        .error (data) ->
          console.log data

]
