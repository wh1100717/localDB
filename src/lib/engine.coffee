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

        key: (index) -> (if @proxy? then @proxy else @storage).key(index)

        size: -> (if @proxy? then @proxy else @storage).size()

        setItem: (key, val) -> (if @proxy? then @proxy else @storage).setItem(key, val)

        getItem: (key) -> (if @proxy? then @proxy else @storage).getItem(key)

        removeItem: (key) -> (if @proxy? then @proxy else @storage).removeItem(key)

        usage: -> (if @proxy? then @proxy else @storage).usage()

    module.exports = Engine