define (require, exports, module) ->
    
    'use strict'

    Evemit = require('lib/evemit')
    Utils = require('lib/utils')

    class Proxy

        constructor: (@session, @encrypt, @token, @proxy) ->
            self = @
            @evemit = new Evemit()
            Evemit.bind window, 'message', (e) ->
                result = JSON.parse e.data
                return if @proxy isnt e.origin
                @evemit.emit result.eve

        sendMessage: (type, data, callback) ->
            self = @
            eve = type + "|" + new Date().getTime()
            data.eve = eve
            data.session = @session
            data.encrypt = @encrypt
            data.token = @token
            @evemit.once eve, callback
            data = JSON.stringify data
            iframe = Utils.getIframe @proxy
            if iframe?
                iframe.contentWindow.postMessage data, @proxy
            else
                iframe = Utils.createIframe @proxy
                iframe.onload = -> iframe.contentWindow.postMessage data, self.proxy

        key: (index, callback) -> @sendMessage 'key', {index: index}, callback

        size: (callback) -> @sendMessage 'size', {}, callback

        setItem: (key, val, callback) -> @sendMessage 'setItem', {key: key, val: val}, callback

        getItem: (key, callback) -> @sendMessage 'getItem', {key: key}, callback

        removeItem: (key, callback) -> @sendMessage 'removeItem', {key: key}, callback

        usage: (callback) -> @sendMessage 'usage', {}, callback


    module.exports = Proxy