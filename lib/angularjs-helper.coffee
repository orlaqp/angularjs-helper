AngularjsHelperView = require './angularjs-helper-view'

module.exports =
    angularjsHelperView: null

    activate: (state) ->
        @angularjsHelperView = new AngularjsHelperView(state.angularjsHelperViewState)

    deactivate: ->
        @angularjsHelperView.destroy()

    serialize: ->
        angularjsHelperViewState: @angularjsHelperView.serialize()
