# #Plugin template

# This is an plugin template and mini tutorial for creating pimatic plugins. It will explain the 
# basics of how the plugin system works and what a plugin should look like.

# ##The plugin code

# Your plugin must export a single function, that takes one argument and returns a instance of
# your plugin class. The parameter is an envirement object containing all pimatic related functions
# and classes. See the [startup.coffee](http://sweetpi.de/pimatic/docs/startup.html) for details.
module.exports = (env) ->

# ###require modules included in pimatic
# To require modules that are included in pimatic use `env.require`. For available packages take
# a look at the dependencies section in pimatics package.json

# Require the  bluebird promise library
  Promise = env.require 'bluebird'

  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'

  # Require the [overkiz-api library](https://github.com/bbriatte/overkiz-api).
  Overkiz = require 'overkiz-api'

  # ###Tahoma class
  # Create a class that extends the Plugin class and implements the following functions:
  class Tahoma extends env.plugins.Plugin

    # ####init()
    # The `init` function is called by the framework to ask your plugin to initialise.
    #  
    # #####params:
    #  * `app` is the [express] instance the framework is using.
    #  * `framework` the framework itself
    #  * `config` the properties the user specified as config for your plugin in the `plugins` 
    #     section of the config.json file 
    #     
    # 
    init: (app, @framework, @config) =>
      user = @config.user
      password = @config.password
      host = @config.host

      deviceConfigDef = require("./device-config-schema")

      env.logger.info("user= #{user}, url=#{host}")
      api = new Overkiz.API({
        host: 'ha101-1.overkiz.com',
        user: user,
        password: password,
        polling: {
          always: false,
          interval: 1000
        }
      });
      api.getDevices()
        .then(env.logger.info)
        .catch(env.logger.error)

      @framework.deviceManager.registerDeviceClass("SomfyShutter", {
        configDef: deviceConfigDef.SomfyShutter,
        createCallback: (config) => new SomfyShutter(config)
      })

    class SomfyShutter extends env.devices.ShutterController
      constructor: (@config, lastState) ->
        @name = @config.name
        @id = @config.id
        @deviceUrl = @config.deviceUrl
        @rollingTime = @config.rollingTime
        @_position = lastState?.position?.value or 'stopped'
        super()

      stop: ->
        @_setPosition('stopped')
        return Promise.resolve()

      # Returns a promise that is fulfilled when done.
      moveToPosition: (position) ->
        @_setPosition(position)
        return Promise.resolve()

      destroy: () ->
        super()


  # ###Finally
  # Create a instance of my plugin
  tahoma = new Tahoma
  # and return it to the framework.
  return tahoma
