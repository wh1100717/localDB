define (require, exports, module) ->
    
    'use strict'

    sendMessage = require("lib/send-message")
    Storage = require('lib/storage')

    class Server
        constructor: (@config) ->
            self = @
            window.addEventListener('message', (e) ->
                origin = e.origin
                isWhite = self.checkOrigin(origin)
                if isWhite is true
                    result = JSON.parse e.data
                    mes = {}
                    mes.type = result.type
                    mes.eve = result.eve
                    session = result.session
                    switch mes.type
                        when "key" 
                            self.Storage = new Storage(session)
                            index = result.index
                            self.Storage.key index, (data) ->
                                mes.data = data
                                self.postParent(mes, origin)

                        when "size" 
                            self.Storage = new Storage(session)
                            self.Storage.size  (data ) ->
                                mes.data = data
                                self.postParent(mes, origin)

                        when "setItem"
                            self.Storage = new Storage(session) 
                            key = result.key
                            val = result.val
                            self.Storage.setItem  key, val, (data ) ->
                                mes.data = data
                                self.postParent(mes, origin)

                        when "getItem"
                            self.Storage = new Storage(session) 
                            key = result.key
                            self.Storage.getItem  key, (data ) ->
                                mes.data = data
                                self.postParent(mes, origin)

                        when "removeItem"
                            self.Storage = new Storage(session) 
                            key = result.key
                            self.Storage.removeItem  key, (data ) ->
                                mes.data = data
                                self.postParent(mes, origin)

                         when "usage"
                            self.Storage = new Storage(session) 
                            self.Storage.usage (data ) ->
                                mes.data = data
                                self.postParent(mes, origin)
                else
                    return false
                
            , false);

        postParent: (mes) -> 
            mes = JSON.stringify mes
            parent.window.postMessage(mes, origin)

        checkOrigin: (origin) ->
            isWhite = false
            whiteList = self.config.whiteList
            for src in whiteList
                if src is origin
                    isWhite = true
                    break
            return isWhite
    module.exports = Server