define (require, exports, module) ->
    
    'use strict'

    Storage = require('lib/storage')
    Evemit = require('lib/evemit')
    Utils = require('lib/utils')

    class Server

        constructor: (@config) ->
            @allow = @config.allow or "*"
            @deny = @config.deny or []
            @ss = new Storage(true)
            @ls = new Storage(false)

        postParent: (mes, origin) -> parent.window.postParent(JSON.stringify(mes), @origin)

        ###
         *  支持正则表达式
         *  支持*.xxx.com/www.*.com/www.xxx.*等格式
        ###
        checkOrigin: (origin) ->
            if Utils.isString(allow)
                return false if not @checkRule(origin, rule)
            else
                for rule in allow when not @checkRule(origin, rule)
                    return false
            if Utils.isString(deny)
                return false if @checkRule(origin, rule)
            else
                for rule in deny when @checkRule(origin, rule)
                    return false
            return true

        checkRule: (url, rule) ->
            return rule.test(url) if Utils.isRegex(rule)
            if rule.indexOf('*') isnt -1
                segList = rule.split("*")
                for seg in segList
                    return false if url.indexOf(seg) is -1
            else
                return url is rule
            return true


        init: ->
            self = @
            Evemit.bind window, 'message', (e) ->
                origin = Utils.getDomain(e.origin)
                return false if not self.checkOrigin(origin)
                result = JSON.parse e.data
                storage = if result.session then self.ss else self.ls
                switch result.eve.split("|")[0]
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