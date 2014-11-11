define (require, exports, module) ->
    
    'use strict'

    sendMessage = require("lib/send-message")

    class Proxy
        constructor: (@config, @session) ->
            self = @
            @sendMessage = sendMessage
            window.addEventListener('message', (e) ->
                result = JSON.parse e.data;
                type = result.type
                eve = result.eve
                data = result.data
                switch type
                    when "key" 
                        if typeof self.key[eve] == "function"
                            self.key[eve](data) 
                            delete self.key[eve]
                    when "size"   
                        if typeof self.size[eve] == "function"
                            self.size[eve](data)
                            delete self.size[eve]
                    when "setItem"
                        if typeof self.setItem[eve] == "function"
                            self.setItem[eve](data)
                            delete self.setItem[eve]
                    when "getItem" 
                        if typeof self.getItem[eve] == "function"
                            self.getItem[eve](data)
                            delete self.getItem[eve]
                    when "removeItem"  
                        if typeof self.removeItem[eve] == "function"
                            self.removeItem[eve](data)
                            delete self.removeItem[eve]
                    when "usage"
                        if typeof self.usage[eve] == "function"
                            self.usage[eve](data)
                            delete self.usage[eve]
            , false)

        key: (index, fn) ->
            id = new Date().getTime();
            eve = "key"+ id
            data = {
                type: "key",
                index: index,
                eve: eve
                session: @session
            }
            @key[eve] = fn 
            @sendMessage(JSON.stringify data)

        size: (fn)-> 
            id = new Date().getTime();
            eve = "size"+ id
            data = {
                type: "size",
                eve: eve,
                session: @session
            }
            @size[eve] = fn 
            @sendMessage(JSON.stringify data)

        setItem: (key, val, fn) -> 
            id = new Date().getTime();
            eve = "setItem"+ id
            data = {
                type: "setItem",
                key: key,
                val: val,
                eve: eve,
                session: @session
            }
            @setItem[eve] = fn 
            @sendMessage(JSON.stringify data)

        getItem: (key, fn) -> 
            id = new Date().getTime();
            eve = "getItem"+ id
            data = {
                type: "getItem",
                key: key,
                eve: eve,
                session: @session
            }
            @getItem[eve] = fn 
            @sendMessage(JSON.stringify data)

        removeItem: (key, fn) -> 
            id = new Date().getTime();
            eve = "removeItem"+ id
            data = {
                type: "removeItem",
                key: key,
                eve: eve,
                session: @session
            }
            @removeItem[eve] = fn 
            @sendMessage(JSON.stringify data)

        usage: (fn) ->
            id = new Date().getTime();
            eve = "usage"+ id
            data = {
                type: "removeItem",
                eve: eve,
                session: @session
            }
            @usage[eve] = fn 
            @sendMessage(JSON.stringify data)

    module.exports = Proxy