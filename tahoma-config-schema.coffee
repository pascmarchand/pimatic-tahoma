# #tahoma configuration options
# Declare your config option for your plugin here. 
module.exports = {
  title: "Tahoma config options"
  type: "object"
  properties:
    consumerKey:
      description: "Consumer Key"
      type: "string"
      default: "foo"
    consumerSecret:
      description: "Consumer Secret"
      type: "string"
      default: "foo"
}