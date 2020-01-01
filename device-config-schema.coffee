module.exports = {
    title: "pimatic-tahoma device config schemas"
    SomfyShutter: {
        title: "Somfy Shutter"
        type: "object"
        properties: {
            deviceUrl:
                description: "Device Url"
                type: "string"
            rollingTime:
                description: "Approx. amount of time (in seconds) for shutter to close or open completely."
                type: "number"
                default: 10
        }
    }
}