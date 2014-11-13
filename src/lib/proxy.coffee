define (require, exports, module) ->
    
    'use strict'

    Evemit = require('lib/evemit')
    Utils = require('lib/utils')

    class Proxy

        constructor: (@expire, @encrypt, @token, @proxy) ->
            self = @
            @evemit = new Evemit()
            Evemit.bind window, 'message', (e) ->
                result = JSON.parse e.data
                return if self.proxy.indexOf(e.origin) is -1
                if result.data?
                    self.evemit.emit result.eve, result.data, result.err
                else
                    self.evemit.emit result.eve, result.err

        sendMessage: (type, data, callback) ->
            self = @
            eve = type + "|" + new Date().getTime()
            data.eve = eve
            data.expire = @expire
            data.encrypt = @encrypt
            data.token = @token
            @evemit.once eve, callback
            data = JSON.stringify data
            iframe = Utils.getIframe @proxy
            if iframe?
                iframe.contentWindow.postMessage data, Utils.getOrigin(@proxy)
            else
                iframe = Utils.createIframe @proxy
                iframe.onload = -> iframe.contentWindow.postMessage data, Utils.getOrigin(self.proxy)

        key: (index, callback) -> @sendMessage 'key', {index: index}, callback

        size: (callback) -> @sendMessage 'size', {}, callback

        setItem: (key, val, callback) -> @sendMessage 'setItem', {key: key, val: val}, callback

        getItem: (key, callback) -> @sendMessage 'getItem', {key: key}, callback

        removeItem: (key, callback) -> @sendMessage 'removeItem', {key: key}, callback

        usage: (callback) -> @sendMessage 'usage', {}, callback


    module.exports = Proxy