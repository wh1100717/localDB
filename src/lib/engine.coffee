define (require, exports, module) ->
    'use strict'

    Support = require('lib/support')
    Storage = require('lib/storage')
    Proxy = require('lib/proxy')

    class Engine

        constructor: (@session, @encrypt, @name, @proxy) ->
            if @proxy?
                @proxy = @proxy.trim()
                @proxy = "http://" + @proxy if @proxy.indexOf("http") is -1
                @proxy = new Proxy(@session, @encrypt, @name, @proxy)
            else
                @storage = new Storage(@session, @encrypt, @name)
            return

        key: (index, callback) -> (if @proxy? then @proxy else @storage).key(index, callback)

        size: (callback) -> (if @proxy? then @proxy else @storage).size(callback)

        setItem: (key, val, callback) -> (if @proxy? then @proxy else @storage).setItem(key, val, callback)

        getItem: (key, callback) -> (if @proxy? then @proxy else @storage).getItem(key, callback)

        removeItem: (key, callback) -> (if @proxy? then @proxy else @storage).removeItem(key, callback)

        usage: (callback) -> (if @proxy? then @proxy else @storage).usage(callback)

    module.exports = Engine