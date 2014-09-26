{View} = require 'atom'
FeatureNameEditorView = require './feature-name-editor-view'
FeatureGenerator = require './feature-generator'

module.exports =
class AngularjsHelperView extends View
  @content: ->
    @div class: 'angularjs-helper overlay from-top', =>
      @div class: "message", =>
        @subview 'filterEditor', new FeatureNameEditorView(placeholderText: 'enter feature name')
      @div class: 'actions', =>
        @button class: 'btn btn-primary', outlet: 'generateBtn', 'Generate'
        @button class: 'btn btn-danger left-margin', outlet: 'cancelBtn', 'Cancel'


  initialize: (serializeState) ->
    generator = new FeatureGenerator()
    atom.workspaceView.command "angularjs-helper:new-feature", => @newFeature()

    @generateBtn.on 'click', =>
      featureName = @filterEditor.getEditor().getText();
      generator.generate(featureName)
      @destroy()

    @cancelBtn.on 'click', =>
      @destroy()



  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  newFeature: ->
    # console.log "Angularjs helper new feature was toggle"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
