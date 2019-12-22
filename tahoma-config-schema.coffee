# #tahoma configuration options
# Declare your config option for your plugin here. 
module.exports = {
  title: "Tahoma config options"
  type: "object"
  properties:
    host:
      description: "Overkiz Api Url"
      type: "string"
      default: "ha101-1.overkiz.com"
    user:
      description: "Tahoma Username"
      type: "string"
      default: ""
      required: yes
    password:
      description: "Tahoma Password"
      type: "string"
      default: ""
      required: yes
}