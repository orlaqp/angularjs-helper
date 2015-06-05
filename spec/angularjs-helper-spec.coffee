{WorkspaceView} = require 'atom-space-pen-views'
AngularjsHelper = require '../lib/angularjs-helper'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "AngularjsHelper", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('angularjs-helper')

  describe "when the angularjs-helper:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.angularjs-helper')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'angularjs-helper:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.angularjs-helper')).toExist()
        atom.workspaceView.trigger 'angularjs-helper:toggle'
        expect(atom.workspaceView.find('.angularjs-helper')).not.toExist()
