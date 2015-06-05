{View, TextEditorView} = require 'atom-space-pen-views'
FeatureGenerator = require './feature-generator'

module.exports =
class AngularjsHelperView extends View
    @content: ->
        @div class: 'angularjs-helper overlay from-top', =>
            @div class: "message", =>
                @subview 'filterEditor', new TextEditorView(placeholderText: 'enter feature name', mini: true)
            @div class: 'actions', =>
                @button class: 'btn btn-primary', click: 'generateFeature', 'Generate'
                @button class: 'btn btn-danger left-margin', click: 'toggle', 'Cancel'


    initialize: (serializeState) ->
        atom.commands.add 'atom-text-editor',
            'angularjs-helper:new-feature': => @toggle()

    generateFeature: ->
        featureName = @filterEditor.getText();

        generator = new FeatureGenerator()
        generator.generate(featureName)

        @toggle()


    toggle: ->
        if @panel?.isVisible()
          @hide()
        else
          @show()

    show: ->
        @panel ?= atom.workspace.addModalPanel(item: this)
        @panel.show()

    hide: ->
        @panel?.hide()
