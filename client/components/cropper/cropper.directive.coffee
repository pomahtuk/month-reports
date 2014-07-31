'use strict'

###
jCrop wrapper
###
angular.module('monthReportsApp').directive 'imgCropped', [
  '$http'
  '$rootScope'
  ($http, $rootScope) ->
    restrict: 'E'
    replace: true
    scope:
      image: '='
      receipts: '='
    template: """
        <div class='cropper-wrap'>
          <img id="target" class="cropper-full" ng-src="{{image.url}}">
          <div class='croppedImages' ng-show='image.croppedImages.length > 0'>
            <div ng-click="openAssignModal(croppedImage)" class='single-cropped-image {{croppedImage._id}}' ng-repeat='croppedImage in image.croppedImages'>
              <div ng-if='croppedImage.receipt'>
                <p>{{croppedImage.receipt.Posted | date: "mediumDate"}}</p>
                <p>Сумма: {{croppedImage.receipt.BilledAmount}}</p>
                <p>{{croppedImage.receipt.MCCDescription}}</p>
              </div>
            </div>
          </div>
          <div class='cropped-controls btn-group' ng-show='showControls'>
            <button type="button" class="btn btn-primary" ng-click="createCropped()">OK</button>
            <button type="button" class="btn btn-warning" ng-click="cancelSelection()">Cancel</button>
          </div>
        </div>
      """
    link: (scope, element, attr) ->

      scope.showControls = false

      element = $ element
      croppingImage = element.find('img')
      cropControls = element.find('.cropped-controls')
      croppedImages = element.find('.croppedImages')
      jCrop = null
      widthAspect = 1
      heightAspect = 1

      scope.cancelSelection = ->
        scope.showControls = false
        jCrop.release?()

      scope.openAssignModal = (image) ->
        $rootScope.$broadcast 'croppedImage:created', image

      scope.createCropped = ->
        console.log 'create'
        selectText = JSON.stringify(scope.image.currentSelection)
        # request below will take about 1 minute to execute, depending on image size
        # console.log scope.image.currentSelection
        $http.post('/api/uploads/crop', {imageId: scope.image._id, coords: selectText}).success (data) ->
          # console.log data
          scope.image.croppedImages.push data
          $rootScope.$broadcast 'croppedImage:created', data
          # create cropped image
        .error (data) ->
          console.log data

      updateSelection = (coords) ->
        scope.image.currentSelection = coords
        true

      finalizeSelection = (coords) ->
        scope.image.currentSelection = coords
        scope.showControls = true
        top = (coords.y2 * heightAspect)
        left = (coords.x2 * widthAspect) - 116
        cropControls.css
          top: top
          left: left
        croppedImages.css
          'z-index': 1000
        true

      croppedImages.click (e) ->
        # console.log 'click'
        unless $(e.target).hasClass 'single-cropped-image'
          croppedImages.find('.single-cropped-image').css
            'z-index': 1
          crop = element.find '.jcrop-tracker'
          crop.trigger 'mousedown', e
          currSelection = jCrop.tellSelect()
          if currSelection.w > 0 and currSelection.h > 0
            scope.showControls = true

      croppingImage.on 'load', ->

        scope.showControls = false

        imageWidth  = croppingImage.get(0).naturalWidth
        imageHeight = croppingImage.get(0).naturalHeight

        widthAspect = croppingImage.width() / imageWidth
        heightAspect = croppingImage.height() / imageHeight

        options =
          bgOpacity: 0.5
          bgColor: 'black'
          boxWidth: croppingImage.width()
          boxHeight: croppingImage.height()
          trueSize: [imageWidth, imageHeight]
          onChange: updateSelection
          onSelect: finalizeSelection
          onRelease: ->
            scope.showControls = false
            croppedImages.find('.single-cropped-image').css
              'z-index': 1000

        jCrop.destroy() if jCrop

        jCrop = null

        croppingImage.Jcrop options, ->
          jCrop = @

          setTimeout ->
            for croppedImage in scope.image.croppedImages
              for receipt in scope.receipts
                if receipt._id is croppedImage.receiptRecord
                  scope.$apply croppedImage.receipt = receipt
                  break
              imageElem = element.find(".#{croppedImage._id}")
              imageElem
                .width croppedImage.selection.w * widthAspect
                .height croppedImage.selection.h * heightAspect
                .css
                  top: croppedImage.selection.y * heightAspect
                  left: croppedImage.selection.x * widthAspect

              # console.log croppedImage.selection, imageElem
          , 200

  ]
