define (require, exports, module) ->
    
    'use strict'

    Support = require('lib/support')
    Storage = require('lib/storage')
    Proxy = require('lib/proxy')

    class Engine

        constructor: (options) ->
            @session = options.session
            @session = true if not @session?
            if options.proxy?
                @proxy = new Proxy(options.proxy, @session)
            else
                @storage = new Storage(@session)
            return

        key: (index, callback) -> (if @proxy? then @proxy else @storage).key(index, callback)

        size: (callback) -> (if @proxy? then @proxy else @storage).size(callback)

        setItem: (key, val, callback) -> (if @proxy? then @proxy else @storage).setItem(key, val, callback)

        getItem: (key, callback) -> (if @proxy? then @proxy else @storage).getItem(key, callback)

        removeItem: (key, callback) -> (if @proxy? then @proxy else @storage).removeItem(key, callback)

        usage: (callback) -> (if @proxy? then @proxy else @storage).usage(callback)

    module.exports = Engine