{allowUnsafeNewFunction} = require 'loophole'

_ = require 'lodash'
fs = require 'fs'
path = require 'path'
handlebars = require 'handlebars'
inflector = require 'inflection'

module.exports =
class FeatureGenerator

    constructor: ->
        @_ensureFolderStructure()

        # define target paths
        appPath = path.join(atom.project.getPaths()[0], '/app')
        jsPath = path.join(appPath, '/js')

        @statesPath = path.join(jsPath, '/states')
        @viewsPath = path.join(appPath, '/views')
        @controllersPath = path.join(jsPath, 'controllers')
        @factoriesPath = path.join(jsPath, 'factories')
        @templatesPath = atom.packages.getPackageDirPaths() + '/angularjs-helper/templates'

    generate: (name) ->
        data =
            entity: inflector.camelize(name)
            entityCamelCase: inflector.camelize(name, true),
            entityCamelCasePluralized: inflector.pluralize(inflector.camelize(name, true)),
            entityPlural: inflector.pluralize(inflector.dasherize(name))
            entityDasherized: inflector.dasherize(name)
            entityHumanized: inflector.humanize(name, true)
            entityHumanizedPlural: inflector.humanize(inflector.pluralize(name))

        # console.log data

        templateFiles = @loadTemplates()

        _.forEach templateFiles, (templateFile) =>
            templateString = fs.readFileSync(path.join(@templatesPath, templateFile), 'utf-8');
            template = handlebars.compile(templateString)
            templateResult = allowUnsafeNewFunction -> template(data)
            @writeOutputFile(data, templateFile, templateResult)
            # console.log templateFile

    _ensureFolderStructure: ->
        mainPath = atom.project.getPaths()[0]
        # app
        fs.mkdir path.join(mainPath, 'app'), ->
            # views
            fs.mkdir path.join(mainPath, 'app', 'views')
            # app/js
            jsPath = path.join(mainPath, 'app', 'js')
            fs.mkdir jsPath, ->
                # states
                fs.mkdir path.join(jsPath, 'states')
                # controllers
                fs.mkdir path.join(jsPath, 'controllers')
                # factories
                fs.mkdir path.join(jsPath, 'factories')


    loadTemplates: ->
        fs.readdirSync(@templatesPath)

    writeOutputFile: (data, templateName, templateResult) ->
        if templateName.indexOf('controller-') != -1
            isCollection = templateName.indexOf('-collection') != -1
            @writeControllerFile(data, isCollection, templateResult)

        if templateName.indexOf('factory-') != -1
            isCollection = templateName.indexOf('-collection') != -1
            @writeFactoryFile(data, isCollection, templateResult)

        if templateName.indexOf('view-') != -1
            isCollection = templateName.indexOf('-collection') != -1
            @writeViewFile(data, isCollection, templateResult)

        if templateName.indexOf('state') != -1
            @writeStateFile(data, templateResult)

    writeControllerFile: (data, isCollection, controller) ->
        featureControllersPath = path.join(@controllersPath, data.entityPlural)
        name = data.entityDasherized
        filename = if isCollection then name + '-collection-controller.js' else name + '-model-controller.js'
        @writeFile(path.join(featureControllersPath, filename), controller)

    writeFactoryFile: (data, isCollection, factory) ->
        featureFactoriesPath = path.join(@factoriesPath, data.entityPlural)
        name = data.entityDasherized
        filename = if isCollection then name + '-collection-factory.js' else name + '-model-factory.js'
        @writeFile(path.join(featureFactoriesPath, filename), factory)

    writeViewFile: (data, isCollection, view) ->
        featureViewsPath = path.join(@viewsPath, '/screens', data.entityPlural)
        filename = if isCollection then 'collection.html' else 'model.html'
        @writeFile(path.join(featureViewsPath, filename), view)

    writeStateFile: (data, state) ->
        @writeFile(path.join(@statesPath, data.entityPlural + '.js'), state)


    createParentFolderIfNeeded: (filename) ->
        dir = path.dirname(filename)
        if (!fs.existsSync(dir))
            fs.mkdir(dir)

    writeFile: (filename, content) ->
        shouldSave = true
        if fs.existsSync(filename)
            atom.confirm
                message: 'Overwrite file?'
                detailedMessage: "File #{filename} already exist do you want to overwrite it?"
                buttons:
                    Yes: -> shouldSave = true
                    No: -> shouldSave = false

        @createParentFolderIfNeeded(filename)

        if shouldSave
            fs.writeFile(filename, content)
