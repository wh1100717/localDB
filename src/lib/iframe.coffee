define (require, exports, module) ->
    'use strict'

    hasIframe = require("lib/has-iframe")

    class Iframe

        constructor: (@src) ->
            self = @
            iframe = new hasIframe(self.src)
            if iframe? 
                return iframe
            else
                iframe = document.createElement("iframe");
                iframe.src = self.config.src;
                iframe.style.display = "none";
                document.body.appendChild(iframe);
                return iframe

    module.exports = Iframe