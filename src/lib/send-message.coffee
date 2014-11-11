define (require, exports, module) ->
    'use strict'

    hasIframe = require("lib/has-iframe")
    Iframe = require("lib/iframe")
    
    class sendMessage

        constructor: (@data, @src) ->
            self = @
            hasIframe = new hasIframe(self.src)
            iframe = new Iframe(self.src)
            if hasIframe? 
                iframe.contentWindow.postMessage(data, self.src);
            else
                iframe.onload = ->
                    iframe.contentWindow.postMessage(data, self.src);

    module.exports = sendMessage