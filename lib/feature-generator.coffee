{allowUnsafeNewFunction} = require 'loophole'

module.exports =
class FeatureGenerator
  _ = require 'lodash'
  fs = require 'fs'
  path = require 'path'
  handlebars = require 'handlebars'
  inflector = require 'inflection'

  # define target paths
  templatesPath = atom.packages.getPackageDirPaths() + '/angularjs-helper/templates'
  appPath = path.join(atom.project.getPath(), '/app')
  jsPath = path.join(appPath, '/js')
  viewsPath = path.join(appPath, '/views')
  controllersPath = path.join(jsPath, 'controllers')
  factoriesPath = path.join(jsPath, 'factories')

  console.log appPath

  generate: (name) ->
    data =
      entity: inflector.camelize(name)
      entityCamelCase: inflector.camelize(name, true),
      entityCamelCasePluralized: inflector.pluralize(inflector.camelize(name, true)),
      entityPlural: inflector.pluralize(inflector.dasherize(name))
      entityDasherized: inflector.dasherize(name)
      entityHumanized: inflector.humanize(name)
      entityHumanizedPlural: inflector.humanize(inflector.pluralize(name))

    console.log data

    templateFiles = @loadTemplates()

    _.forEach templateFiles, (templateFile) =>
      templateString = fs.readFileSync(path.join(templatesPath, templateFile), 'utf-8');
      template = handlebars.compile(templateString)
      templateResult = allowUnsafeNewFunction -> template(data)
      @writeOutputFile(data, templateFile, templateResult)
      console.log templateFile

  loadTemplates: ->
    fs.readdirSync(templatesPath)

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

  writeControllerFile: (data, isCollection, controller) ->
    featureControllersPath = path.join(controllersPath, data.entityPlural)
    if (!fs.existsSync(featureControllersPath))
      fs.mkdir(featureControllersPath)

    name = data.entityDasherized
    filename = if isCollection then name + '-collection-controller.js' else name + '-model-controller.js'
    fs.writeFile(path.join(featureControllersPath, filename), controller)

  writeFactoryFile: (data, isCollection, factory) ->
    featureFactoriesPath = path.join(factoriesPath, data.entityPlural)
    if (!fs.existsSync(featureFactoriesPath))
      fs.mkdir(featureFactoriesPath)

    name = data.entityDasherized
    filename = if isCollection then name + '-collection-factory.js' else name + '-model-factory.js'
    fs.writeFile(path.join(featureFactoriesPath, filename), factory)

  writeViewFile: (data, isCollection, view) ->
    featureViewsPath = path.join(viewsPath, '/screens', data.entityPlural)
    if (!fs.existsSync(featureViewsPath))
      fs.mkdir(featureViewsPath)

    name = data.entityDasherized
    filename = if isCollection then name + '-collection.html' else name + '-model.html'
    fs.writeFile(path.join(featureViewsPath, filename), view)
