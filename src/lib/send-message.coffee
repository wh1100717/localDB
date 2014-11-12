define (require, exports, module) ->

    'use strict'

    Utils = require('lib/utils')

    class SendMessage

        constructor: (@data, @src) ->
            self = @
            iframe = Utils.getIframe @src
            if iframe?
                iframe.contentWindow.postMessage @data, @src
            else
                iframe = Utils.createIfram @src
                iframe.onload = -> iframe.contentWindow.postMessage(self.data, self.src)

    module.exports = SendMessage