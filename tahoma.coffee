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
        host: host,
        user: user,
        password: password,
        polling: {
          always: false,
          interval: 1000
        }
      });
      @loadDevices = api.getDevices()

      @framework.deviceManager.on('discover', (eventData) =>

        @framework.deviceManager.discoverMessage(
          'pimatic-tahoma', "Waiting for Tahoma devices"
        )

        @loadDevices.then((devices) =>
          for device in devices
            if device.uiClass is 'RollerShutter'
              config = {
                "id": "#{device.name}-shutter",
                "name": device.name,
                "class": "SomfyShutter",
                "deviceUrl": device.URL
              }
              @framework.deviceManager.discoveredDevice(
                'pimatic-tahoma', device.name, config
              )
        )
      )

      @framework.deviceManager.registerDeviceClass("SomfyShutter", {
        configDef: deviceConfigDef.SomfyShutter,
        createCallback: (config, lastState) => new SomfyShutter(config, lastState, @loadDevices)
      })

    class SomfyShutter extends env.devices.ShutterController
      constructor: (@config, lastState, devices) ->
        @name = @config.name
        @id = @config.id
        @deviceUrl = @config.deviceUrl
        @rollingTime = @config.rollingTime
        @_position = lastState?.position?.value or 'stopped'

        devices.then((dev) =>
          for device in dev
            if @deviceUrl is device.URL
              assert device.uiClass is 'RollerShutter', "Device isn't a shutter"
              env.logger.info "Init shutter #{@name} with id #{@deviceUrl}"
              @_device = device
              return
          env.logger.error "Shutter #{@name} couldn't be initialized"
        ).catch(env.logger.error);
        super()

      stop: ->
        @_setPosition('stopped')
        return Promise.resolve()

      # Returns a promise that is fulfilled when done.
      moveToPosition: (position) ->
        percentage = if position is 'down' then 100 else 0
        @_device.exec({
          name: "setClosure",
          parameters: [percentage]
        }).then(@_setPosition(position))
          .catch(env.logger.error);
        return Promise.resolve()

      destroy: () ->
        super()


  # ###Finally
  # Create a instance of my plugin
  tahoma = new Tahoma
  # and return it to the framework.
  return tahoma
