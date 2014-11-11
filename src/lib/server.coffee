define (require, exports, module) ->
    
    'use strict'

    Storage = require('lib/storage')
    Evemit = require('lib/evemit')

    class Server

        constructor: (@config) ->
            @allow = @config.allow or "*"
            @deny = @config.deny or []
            @ss = new Storage(true)
            @ls = new Storage(false)

        postParent: (mes, origin) -> parent.window.postParent(JSON.stringify(mes), @origin)

        checkOrigin: (origin) -> origin in @allow

        init: ->
            self = @
            Evemit.bind 'message', (e) ->
                origin = e.origin
                return false if not self.checkOrigin(origin)
                result = JSON.parse e.data
                storage = if result.session then self.ss else self.ls
                switch result.type
                    when "key"
                        storage.key result.index, (data, err) ->
                            result.data = data
                            result.err = err
                            self.postParent(result, origin)
                    when "size"
                        storage.size (data, err) ->
                            result.data = data
                            result.err = err
                            self.postParent(result, origin)
                    when "setItem"
                        storage.setItem result.key, result.val, (err) ->
                            result.err = err
                            self.postParent(result, origin)
                    when "getItem"
                        storage.getItem result.key, (data, err) ->
                            result.data = data
                            result.err = err
                            self.postParent(result, origin)
                    when "removeItem"
                        storage.removeItem result.key, (err) ->
                            result.err = err
                            self.postParent(result, origin)
                    when "usage"
                        storage.usage (data, err) ->
                            result.data = data
                            result.err = err
                            self.postParent(result, origin)
    module.exports = Server